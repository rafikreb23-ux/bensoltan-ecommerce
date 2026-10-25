Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices.Marshal -ErrorAction SilentlyContinue
$src = "$env:TEMP\stock-image.jpg"
$outDir = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets"
if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height
Write-Output "Sheet: ${W}x${H}"

# Fast pixel read via LockBits (24bpp)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bd = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$stride = $bd.Stride
$bytes = New-Object 'byte[]' ($stride * $H)
[System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $bytes, 0, ($stride * $H))
$bmp.UnlockBits($bd)

# Dark mask
$dark = New-Object 'bool[]' ($W * $H)
for ([int]$y = 0; $y -lt $H; $y++) {
  for ([int]$x = 0; $x -lt $W; $x++) {
    [int]$o = ($y * $stride) + ($x * 3)
    [int]$lum = [int](($bytes[$o] + $bytes[$o+1] + $bytes[$o+2]) / 3)
    if ($lum -lt 160) { $dark[($y * $W) + $x] = $true }
  }
}
[int]$darkTotal = 0
foreach ($d in $dark) { if ($d) { $darkTotal++ } }
Write-Output "Dark pixels total: $darkTotal"

# Pass 1: connected components (8-conn BFS)
function Find-Components($mask, $W, $H) {
  $visited = New-Object 'bool[]' ($W * $H)
  $comps = New-Object System.Collections.Generic.List[object]
  $stack = New-Object System.Collections.Generic.List[int]
  for ([int]$p = 0; $p -lt ($W * $H); $p++) {
    if ($mask[$p] -and (-not $visited[$p])) {
      $stack.Clear()
      $stack.Add($p)
      $visited[$p] = $true
      [int]$minX = $W; [int]$maxX = 0; [int]$minY = $H; [int]$maxY = 0; [int]$cnt = 0
      while ($stack.Count -gt 0) {
        [int]$q = $stack[$stack.Count - 1]
        $stack.RemoveAt($stack.Count - 1)
        [int]$px = [int][Math]::Floor($q / $W)
        [int]$py = $q % $W
        $cnt++
        if ($py -lt $minX) { $minX = $py }
        if ($py -gt $maxX) { $maxX = $py }
        if ($px -lt $minY) { $minY = $px }
        if ($px -gt $maxY) { $maxY = $px }
        for ([int]$dx = -1; $dx -le 1; $dx++) {
          for ([int]$dy = -1; $dy -le 1; $dy++) {
            [int]$nx = $py + $dx
            [int]$ny = $px + $dy
            if ($nx -ge 0 -and $nx -lt $W -and $ny -ge 0 -and $ny -lt $H) {
              [int]$np = ($ny * $W) + $nx
              if ($mask[$np] -and (-not $visited[$np])) {
                $visited[$np] = $true
                $stack.Add($np)
              }
            }
          }
        }
      }
      $comps.Add(@{ MinX = $minX; MaxX = $maxX; MinY = $minY; MaxY = $maxY; Count = $cnt })
    }
  }
  return $comps
}

$comps1 = Find-Components $dark $W $H
Write-Output "Pass-1 components: $($comps1.Count)"
$big = $comps1 | Where-Object { $_.Count -gt $darkTotal * 0.3 }
if ($big) {
  Write-Output "GIANT component detected (probably frame/watermark) - count: $($big.Count), bbox: $($big[0].MinX),$($big[0].MinY) - $($big[0].MaxX),$($big[0].MaxY)"
  # Remove giant component pixels from mask: re-BFS only that component and clear it
  # Simpler: remove pixels that belong to any component whose bbox covers >85% of sheet width or height AND count < 25% pixels (thin frame)
  $toClear = New-Object 'bool[]' ($W * $H)
  foreach ($c in $comps1) {
    [int]$bw = $c.MaxX - $c.MinX + 1
    [int]$bh = $c.MaxY - $c.MinY + 1
    if ((($bw -ge ($W * 0.85)) -or ($bh -ge ($H * 0.85))) -and ($c.Count -lt ($darkTotal * 0.25))) {
      # mark this component's pixels via region scan of mask within bbox... need its pixels: re-run BFS limited - easier: mark by flood from any seed? Approximation: mark all dark pixels inside bbox that were part of giant comps - we don't have pixel lists.
    }
  }
}

# If pass-1 yielded ONE giant comp touching everything, do erosion-based separation instead:
if ($comps1.Count -le 3) {
  Write-Output "Icons appear CONNECTED - applying gap-based column/row profiling with HIGHER thresholds..."
}

# Diagnostic: column density profile (every 25px)
Write-Output "Column density profile (x:density):"
for ([int]$x = 0; $x -lt $W; $x += 25) {
  [int]$c2 = 0
  for ([int]$y = 0; $y -lt $H; $y++) { if ($dark[($y * $W) + $x]) { $c2++ } }
  Write-Output -NoNewline "$x`:$c2  "
}
Write-Output ""
Write-Output "Row density profile (y:density):"
for ([int]$y = 0; $y -lt $H; $y += 25) {
  [int]$r2 = 0
  for ([int]$x = 0; $x -lt $W; $x++) { if ($dark[($y * $W) + $x]) { $r2++ } }
  Write-Output -NoNewline "$y`:$r2  "
}
Write-Output ""

# Show top-10 components by size
$top = $comps1 | Sort-Object { -($_.Count) } | Select-Object -First 10
foreach ($t in $top) {
  Write-Output "COMP: size=$($t.Count) bbox=($($t.MinX),$($t.MinY))-$($t.MaxX),$($t.MaxY)"
}

$img.Dispose()
$bmp.Dispose()
