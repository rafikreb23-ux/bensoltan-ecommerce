# ============================================================
# ICON STANDARD SCRIPT (the standard for ALL future icons)
# Usage: powershell -File icon-standard.ps1 <source> <output>
# Process: content-crop (alpha bbox, no empty margins) -> 256px max -> PNG
# ============================================================
param(
  [Parameter(Mandatory = $true)][string]$InputPath,
  [Parameter(Mandatory = $true)][string]$OutputPath
)
Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Image]::FromFile($InputPath)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height

# 1) Content bounding box (visible pixels only)
[int]$x0 = $W; [int]$x1 = 0; [int]$y0 = $H; [int]$y1 = 0
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    if ($bmp.GetPixel($x, $y).A -gt 100) {
      if ($x -lt $x0) { $x0 = $x }
      if ($x -gt $x1) { $x1 = $x }
      if ($y -lt $y0) { $y0 = $y }
      if ($y -gt $y1) { $y1 = $y }
    }
  }
}
if (($x1 -lt $x0) -or ($y1 -lt $y0)) { Write-Output "ERROR: no visible content"; exit 1 }
[int]$fillX = [int](($x1 - $x0 + 1) * 100 / $W)
[int]$fillY = [int](($y1 - $y0 + 1) * 100 / $H)
Write-Output "Source ${W}x${H} | content fill: ${fillX}% x ${fillY}%"

# 2) Crop with 6px margin
[int]$m = 6
$x0 = [Math]::Max(0, $x0 - $m); $y0 = [Math]::Max(0, $y0 - $m)
$x1 = [Math]::Min($W - 1, $x1 + $m); $y1 = [Math]::Min($H - 1, $y1 + $m)
[int]$cw = $x1 - $x0 + 1; [int]$ch = $y1 - $y0 + 1
$crop = New-Object System.Drawing.Bitmap($cw, $ch)
$g = [System.Drawing.Graphics]::FromImage($crop)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $cw, $ch)), (New-Object System.Drawing.Rectangle($x0, $y0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

# 3) Resize so max dimension = 256
[double]$ratio = 256 / [Math]::Max($cw, $ch)
[int]$nw = [int]([Math]::Round($cw * $ratio)); [int]$nh = [int]([Math]::Round($ch * $ratio))
$final = New-Object System.Drawing.Bitmap($nw, $nh)
$g2 = [System.Drawing.Graphics]::FromImage($final)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.DrawImage($crop, 0, 0, $nw, $nh)
$g2.Dispose()

# 4) Save
$final.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Standard icon saved: ${nw}x${nh} ($([math]::Round((Get-Item $OutputPath).Length/1KB)) KB) -> $OutputPath"
$crop.Dispose(); $final.Dispose(); $img.Dispose(); $bmp.Dispose()
