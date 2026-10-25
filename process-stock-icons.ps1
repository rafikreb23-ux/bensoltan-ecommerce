Add-Type -AssemblyName System.Drawing
$src = "$env:TEMP\stock-image.jpg"
$outDir = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets"
if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height
Write-Output "Sheet: ${W}x${H}"

# Precompute: dark-pixel count per column (full height)
$colCount = New-Object 'int[]' $W
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [int]$lum = [int](($c.R + $c.G + $c.B) / 3)
    if ($lum -lt 160) { $colCount[$x] = $colCount[$x] + 1 }
  }
}
[int]$maxCol = ($colCount | Measure-Object -Maximum).Maximum
[int]$colTh = [Math]::Max(8, [int]($maxCol * 0.08))
Write-Output "Max col density: $maxCol | threshold: $colTh"

# Column bands by density
$colBands = New-Object System.Collections.Generic.List[string]
[bool]$inBand = $false
[int]$bandStart = -1
for ([int]$x = 0; $x -lt $W; $x++) {
  [bool]$has = ($colCount[$x] -ge $colTh)
  if ($has -and (-not $inBand)) { $inBand = $true; $bandStart = $x }
  if ((-not $has) -and $inBand) {
    $inBand = $false
    if (($x - $bandStart) -ge 30) { $colBands.Add("$bandStart|$($x - 1)") }
  }
}
if ($inBand -and (($W - $bandStart) -ge 30)) { $colBands.Add("$bandStart|$($W - 1)") }
Write-Output "Column bands: $($colBands.Count)"

# Extract icon cells: rows within each column band by density
$cells = New-Object System.Collections.Generic.List[string]
foreach ($cb in $colBands) {
  $parts = $cb.Split('|')
  [int]$x0 = [int]$parts[0]
  [int]$x1 = [int]$parts[1]
  [int]$bandWidth = ($x1 - $x0) + 1
  [int]$rowTh = [Math]::Max(6, [int]($bandWidth * 0.08))
  # per-row dark count inside this band
  $bandRows = New-Object 'int[]' $H
  for ([int]$y = 0; $y -lt $H; $y++) {
    for ([int]$x = $x0; $x -le $x1; $x++) {
      $c = $bmp.GetPixel($x, $y)
      [int]$lum = [int](($c.R + $c.G + $c.B) / 3)
      if ($lum -lt 160) { $bandRows[$y] = $bandRows[$y] + 1 }
    }
  }
  [bool]$inB = $false
  [int]$s = -1
  for ([int]$y = 0; $y -lt $H; $y++) {
    [bool]$has = ($bandRows[$y] -ge $rowTh)
    if ($has -and (-not $inB)) { $inB = $true; $s = $y }
    if ((-not $has) -and $inB) {
      $inB = $false
      if (($y - $s) -ge 30) { $cells.Add("$x0|$s|$x1|$($y - 1)") }
    }
  }
  if ($inB -and (($H - $s) -ge 30)) { $cells.Add("$x0|$s|$x1|$($H - 1)") }
}
Write-Output "Icon cells: $($cells.Count)"

# Recolor constants (site blue)
[byte]$BR = 30; [byte]$BG = 64; [byte]$BB = 175

# Extract + recolor each cell
[int]$i = 0
foreach ($cellStr in $cells) {
  $p = $cellStr.Split('|')
  [int]$x0 = [int]$p[0]; [int]$y0 = [int]$p[1]; [int]$x1 = [int]$p[2]; [int]$y1 = [int]$p[3]
  if ($x0 -gt 6) { $x0 = $x0 - 6 }
  if ($y0 -gt 6) { $y0 = $y0 - 6 }
  if ($x1 -lt ($W - 7)) { $x1 = $x1 + 6 }
  if ($y1 -lt ($H - 7)) { $y1 = $y1 + 6 }
  [int]$cw = ($x1 - $x0) + 1
  [int]$ch = ($y1 - $y0) + 1
  $nb = New-Object System.Drawing.Bitmap($cw, $ch)
  for ([int]$x = 0; $x -lt $cw; $x++) {
    for ([int]$y = 0; $y -lt $ch; $y++) {
      $c = $bmp.GetPixel(($x0 + $x), ($y0 + $y))
      [int]$lum = [int](($c.R + $c.G + $c.B) / 3)
      [int]$a = 255 - $lum
      if ($a -lt 12) { $a = 0 }
      $nb.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $BR, $BG, $BB))
    }
  }
  $nb.Save("$outDir\icon-$i.png", [System.Drawing.Imaging.ImageFormat]::Png)
  $nb.Dispose()
  $i++
}
Write-Output "Saved $i icon PNGs"

# Full sheet recolored on white
$full = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [double]$lum = [double](($c.R + $c.G + $c.B) / 3)
    [double]$alpha = (255 - $lum) / 255.0
    [int]$r = [int](([double]$BR * $alpha) + (255 * (1 - $alpha)))
    [int]$g = [int](([double]$BG * $alpha) + (255 * (1 - $alpha)))
    [int]$b = [int](([double]$BB * $alpha) + (255 * (1 - $alpha)))
    $full.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($r, $g, $b))
  }
}
$full.Save("$outDir\sheet-blue.png", [System.Drawing.Imaging.ImageFormat]::Png)
$full.Dispose()
$bmp.Dispose()
$img.Dispose()
Write-Output "DONE"
