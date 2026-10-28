# Wholesale of Various Materials1.png (opaque, white bg) -> wholesale-materials1-gradient.png
# Remove white bg -> transparent, apply Wholesale gradient, pad to square, max 256
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\Wholesale of Various Materials1.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
Write-Output "Source: ${W}x${H} (opaque, removing white bg)"
# Extract: white -> transparent, keep dark lines, apply Wholesale gradient
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236
$res = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    [int]$a = 255 - $lum
    if ($a -lt 30) { $a = 0 }
    [double]$t = $y / [double]$H
    [int]$r = [int]($tR + (($bR - $tR) * $t))
    [int]$gg = [int]($tG + (($bG - $tG) * $t))
    [int]$b = [int]($tB + (($bB - $tB) * $t))
    $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
  }
}
# Find content bounds
[int]$x0 = $W; [int]$x1 = 0; [int]$y0 = $H; [int]$y1 = 0
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    if ($res.GetPixel($x, $y).A -gt 20) {
      if ($x -lt $x0) { $x0 = $x }; if ($x -gt $x1) { $x1 = $x }
      if ($y -lt $y0) { $y0 = $y }; if ($y -gt $y1) { $y1 = $y }
    }
  }
}
[int]$m = 4
$cx0 = [Math]::Max(0, $x0 - $m); $cy0 = [Math]::Max(0, $y0 - $m)
$cx1 = [Math]::Min($W - 1, $x1 + $m); $cy1 = [Math]::Min($H - 1, $y1 + $m)
[int]$cw = $cx1 - $cx0 + 1; [int]$ch = $cy1 - $cy0 + 1
Write-Output "Content: ($cx0,$cy0)-($cx1,$cy1) => ${cw}x${ch}"
# Crop and pad to square
$clean = New-Object System.Drawing.Bitmap($cw, $ch)
$g = [System.Drawing.Graphics]::FromImage($clean)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($res, (New-Object System.Drawing.Rectangle(0, 0, $cw, $ch)), (New-Object System.Drawing.Rectangle($cx0, $cy0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
[int]$S = [Math]::Max($cw, $ch)
$padded = New-Object System.Drawing.Bitmap($S, $S)
$g2 = [System.Drawing.Graphics]::FromImage($padded)
[int]$dx = [int](($S - $cw) / 2)
[int]$dy = [int](($S - $ch) / 2)
$g2.DrawImage($clean, (New-Object System.Drawing.Rectangle($dx, $dy, $cw, $ch)))
$g2.Dispose()
# Scale to 256
[int]$nw = $S; [int]$nh = $S
if ($S -gt 256) {
  [double]$ratio = 256.0 / $S
  $nw = [int]([Math]::Round($S * $ratio))
  $nh = [int]([Math]::Round($S * $ratio))
}
$final = New-Object System.Drawing.Bitmap($nw, $nh)
$g3 = [System.Drawing.Graphics]::FromImage($final)
$g3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g3.DrawImage($padded, (New-Object System.Drawing.Rectangle(0, 0, $nw, $nh)))
$g3.Dispose()
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\wholesale-materials1-gradient.png"
$final.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "wholesale-materials1-gradient.png: ${nw}x${nh} ($([math]::Round((Get-Item $out).Length/1KB)) KB)"
$final.Dispose(); $padded.Dispose(); $clean.Dispose(); $res.Dispose(); $img.Dispose(); $bmp.Dispose()