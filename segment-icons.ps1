Add-Type -AssemblyName System.Drawing
$src = "$env:TEMP\stock-image.jpg"
$outDir = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets"
if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height

$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bd = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$stride = $bd.Stride
$bytes = New-Object 'byte[]' ($stride * $H)
[System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $bytes, 0, ($stride * $H))
$bmp.UnlockBits($bd)

$dark = New-Object 'bool[]' ($W * $H)
for ([int]$y = 0; $y -lt $H; $y++) {
  for ([int]$x = 0; $x -lt $W; $x++) {
    [int]$o = ($y * $stride) + ($x * 3)
    [int]$lum = [int](($bytes[$o] + $bytes[$o+1] + $bytes[$o+2]) / 3)
    if ($lum -lt 160) { $dark[($y * $W) + $x] = $true }
  }
}

# Connected components with pixel counts
$visited = New-Object 'bool[]' ($W * $H)
$all = New-Object System.Collections.Generic.List[int[]]
$stack = New-Object System.Collections.Generic.List[int]
for ([int]$p = 0; $p -lt ($W * $H); $p++) {
  if ($dark[$p] -and (-not $visited[$p])) {
    $stack.Clear(); $stack.Add($p); $visited[$p] = $true
    [int]$minX = $W; [int]$maxX = 0; [int]$minY = $H; [int]$maxY = 0; [int]$cnt = 0
    while ($stack.Count -gt 0) {
      [int]$q = $stack[$stack.Count - 1]
      $stack.RemoveAt($stack.Count - 1)
      [int]$px = [Math]::Floor($q / $W)
      [int]$py = $q % $W
      $cnt++
      if ($py -lt $minX) { $minX = $py }
      if ($py -gt $maxX) { $maxX = $py }
      if ($px -lt $minY) { $minY = $px }
      if ($px -gt $maxY) { $maxY = $px }
      for ([int]$dx = -1; $dx -le 1; $dx++) {
        for ([int]$dy = -1; $dy -le 1; $dy++) {
          [int]$nx = $py + $dx; [int]$ny = $px + $dy
          if ($nx -ge 0 -and $nx -lt $W -and $ny -ge 0 -and $ny -lt $H) {
            [int]$np = ($ny * $W) + $nx
            if ($dark[$np] -and (-not $visited[$np])) { $visited[$np] = $true; $stack.Add($np) }
          }
        }
      }
    }
    $all.Add(@($minX, $minY, $maxX, $maxY, $cnt))
  }
}

# Candidate icons: bbox >= 55x55 AND pixel count >= 300
$cands = New-Object System.Collections.Generic.List[int[]]
foreach ($b in $all) {
  if ((($b[2] - $b[0]) -ge 55) -and (($b[3] - $b[1]) -ge 55) -and ($b[4] -ge 300)) { $cands.Add($b) }
}
Write-Output "Candidates: $($cands.Count)"

# Remove boxes contained inside bigger boxes (inner parts of icons)
$icons = New-Object System.Collections.Generic.List[int[]]
for ([int]$i = 0; $i -lt $cands.Count; $i++) {
  [bool]$contained = $false
  for ([int]$j = 0; $j -lt $cands.Count; $j++) {
    if ($i -ne $j) {
      $a = $cands[$i]; $b = $cands[$j]
      if (($a[0] -ge $b[0]) -and ($a[1] -ge $b[1]) -and ($a[2] -le $b[2]) -and ($a[3] -le $b[3]) -and ($b[4] -gt $a[4])) { $contained = $true; break }
    }
  }
  if (-not $contained) { $icons.Add($cands[$i]) }
}
Write-Output "Individual icons after dedup: $($icons.Count)"

# Sort by reading order (top-to-bottom, right-to-left for RTL sheet? use left-to-right, top-to-bottom)
$sorted = $icons | Sort-Object { $_[1] }, { $_[0] }
$icons = $sorted

# Extract + recolor
[byte]$BR = 30; [byte]$BG = 64; [byte]$BB = 175
[int]$i = 0
foreach ($b in $icons) {
  [int]$x0 = [Math]::Max(0, $b[0] - 8); [int]$y0 = [Math]::Max(0, $b[1] - 8)
  [int]$x1 = [Math]::Min($W - 1, $b[2] + 8); [int]$y1 = [Math]::Min($H - 1, $b[3] + 8)
  [int]$cw = ($x1 - $x0) + 1; [int]$ch = ($y1 - $y0) + 1
  $nb = New-Object System.Drawing.Bitmap($cw, $ch)
  for ([int]$x = 0; $x -lt $cw; $x++) {
    for ([int]$y = 0; $y -lt $ch; $y++) {
      [int]$o = (($y0 + $y) * $stride) + (($x0 + $x) * 3)
      [int]$lum = [int](($bytes[$o] + $bytes[$o+1] + $bytes[$o+2]) / 3)
      [int]$a = 255 - $lum
      if ($a -lt 12) { $a = 0 }
      $nb.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $BR, $BG, $BB))
    }
  }
  $nb.Save("$outDir\shape-$i.png", [System.Drawing.Imaging.ImageFormat]::Png)
  $nb.Dispose()
  Write-Output "shape-$i : ($($b[0]),$($b[1]))-($($b[2]),$($b[3])) size=$($b[4])"
  $i++
}
Write-Output "SAVED $i individual shapes"
$img.Dispose(); $bmp.Dispose()
