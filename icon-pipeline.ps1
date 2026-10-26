# Full standard pipeline: recolor -> cleanup (connected components) -> content-crop -> preview asset
param(
  [Parameter(Mandatory = $true)][string]$InputPath,
  [Parameter(Mandatory = $true)][string]$OutputPath,
  [int]$MaxDim = 256
)
Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Image]::FromFile($InputPath)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height
Write-Output "Source: ${W}x${H}"

# 1) Recolor: luminance -> alpha, site blue
[byte]$BR = 30; [byte]$BG = 64; [byte]$BB = 175
$rec = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    [int]$a = 255 - $lum
    if ($a -lt 12) { $a = 0 }
    $rec.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $BR, $BG, $BB))
  }
}
Write-Output "Recolored to site blue"

# 2) Connected-components cleanup: keep the largest design component only
$mask = New-Object 'bool[]' ($W * $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $mask[($y * $W) + $x] = ($rec.GetPixel($x, $y).A -gt 110)
  }
}
$visited = New-Object 'bool[]' ($W * $H)
$stack = New-Object System.Collections.Generic.List[int]
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
Write-Output "Main design: $bestSize px"
$keep = New-Object 'bool[]' ($W * $H)
foreach ($q in $bestPixels) { $keep[$q] = $true }
[int]$removed = 0
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    if (-not $keep[($y * $W) + $x]) { $rec.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $BR, $BG, $BB)); $removed++ }
  }
}
Write-Output "Junk removed: $removed px"

# 3) Content-crop (bbox of main design) + 6px margin
[int]$x0 = $W; [int]$x1 = 0; [int]$y0 = $H; [int]$y1 = 0
foreach ($q in $bestPixels) {
  [int]$py = [Math]::Floor($q / $W); [int]$px = $q % $W
  if ($px -lt $x0) { $x0 = $px }; if ($px -gt $x1) { $x1 = $px }
  if ($py -lt $y0) { $y0 = $py }; if ($py -gt $y1) { $y1 = $py }
}
[int]$m = 6
$cx0 = [Math]::Max(0, $x0 - $m); $cy0 = [Math]::Max(0, $y0 - $m)
$cx1 = [Math]::Min($W - 1, $x1 + $m); $cy1 = [Math]::Min($H - 1, $y1 + $m)
[int]$cw = $cx1 - $cx0 + 1; [int]$ch = $cy1 - $cy0 + 1
Write-Output "Content: ($x0,$y0)-($x1,$y1) -> crop ${cw}x${ch}"

# 4) Resize only if BIGGER than MaxDim (never upscale)
[int]$nw = $cw; [int]$nh = $ch
if (($cw -gt $MaxDim) -or ($ch -gt $MaxDim)) {
  [double]$ratio = $MaxDim / [Math]::Max($cw, $ch)
  $nw = [int]([Math]::Round($cw * $ratio)); $nh = [int]([Math]::Round($ch * $ratio))
}
$final = New-Object System.Drawing.Bitmap($nw, $nh)
$g = [System.Drawing.Graphics]::FromImage($final)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($rec, (New-Object System.Drawing.Rectangle(0, 0, $nw, $nh)), (New-Object System.Drawing.Rectangle($cx0, $cy0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$final.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "FINAL: ${nw}x${nh} -> $OutputPath ($([math]::Round((Get-Item $OutputPath).Length/1KB)) KB)"
$final.Dispose(); $rec.Dispose(); $img.Dispose(); $bmp.Dispose()
