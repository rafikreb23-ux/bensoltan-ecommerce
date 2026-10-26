Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\certified-wood.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height

# 1) Alpha mask (>110)
$mask = New-Object 'bool[]' ($W * $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $mask[($y * $W) + $x] = ($bmp.GetPixel($x, $y).A -gt 110)
  }
}

# 2) Connected components — find the LARGEST (the real design)
$visited = New-Object 'bool[]' ($W * $H)
$stack = New-Object System.Collections.Generic.List[int]
[object]$best = $null
[long]$bestSize = 0
$bestPixels = $null
for ([int]$p = 0; $p -lt ($W * $H); $p++) {
  if ($mask[$p] -and (-not $visited[$p])) {
    $stack.Clear(); $stack.Add($p); $visited[$p] = $true
    $pixels = New-Object System.Collections.Generic.List[int]
    while ($stack.Count -gt 0) {
      [int]$q = $stack[$stack.Count - 1]
      $stack.RemoveAt($stack.Count - 1)
      $pixels.Add($q)
      [int]$py = [Math]::Floor($q / $W); [int]$px = $q % $W
      for ([int]$dx = -1; $dx -le 1; $dx++) {
        for ([int]$dy = -1; $dy -le 1; $dy++) {
          [int]$nx = $px + $dx; [int]$ny = $py + $dy
          if ($nx -ge 0 -and $nx -lt $W -and $ny -ge 0 -and $ny -lt $H) {
            [int]$np = ($ny * $W) + $nx
            if ($mask[$np] -and (-not $visited[$np])) { $visited[$np] = $true; $stack.Add($np) }
          }
        }
      }
    }
    if ($pixels.Count -gt $bestSize) { $bestSize = $pixels.Count; $bestPixels = $pixels }
  }
}
Write-Output "Largest component (the design): $bestSize px"

# 3) Keep ONLY the design component: clear everything else + faint pixels
[byte]$BR = 30; [byte]$BG = 64; [byte]$BB = 175
$keep = New-Object 'bool[]' ($W * $H)
foreach ($q in $bestPixels) { $keep[$q] = $true }
[int]$removed = 0
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    [int]$p = ($y * $W) + $x
    if (-not $keep[$p]) { $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $BR, $BG, $BB)); $removed++ }
  }
}
Write-Output "Removed junk pixels: $removed"

# 4) Content-crop + 6px margin
[int]$x0 = $W; [int]$x1 = 0; [int]$y0 = $H; [int]$y1 = 0
foreach ($q in $bestPixels) {
  [int]$py = [Math]::Floor($q / $W); [int]$px = $q % $W
  if ($px -lt $x0) { $x0 = $px }; if ($px -gt $x1) { $x1 = $px }
  if ($py -lt $y0) { $y0 = $py }; if ($py -gt $y1) { $y1 = $py }
}
[int]$m = 6
$x0 = [Math]::Max(0, $x0 - $m); $y0 = [Math]::Max(0, $y0 - $m)
$x1 = [Math]::Min($W - 1, $x1 + $m); $y1 = [Math]::Min($H - 1, $y1 + $m)
[int]$cw = $x1 - $x0 + 1; [int]$ch = $y1 - $y0 + 1
$nb = New-Object System.Drawing.Bitmap($cw, $ch)
$g = [System.Drawing.Graphics]::FromImage($nb)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $cw, $ch)), (New-Object System.Drawing.Rectangle($x0, $y0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
Write-Output "Cleaned + cropped: ${cw}x${ch}"

# 5) Save to temp then replace (avoid file lock)
$img.Dispose()
$tmpOut = "$env:TEMP\certified-wood-fixed.png"
$nb.Save($tmpOut, [System.Drawing.Imaging.ImageFormat]::Png)
$nb.Dispose()
Move-Item $tmpOut $src -Force
Write-Output "Saved (replaced): $src ($([math]::Round((Get-Item $src).Length/1KB)) KB)"
