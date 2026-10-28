# Wholesale of Various Materials1.png -> wholesale-trading-large.png
# Tight crop on illustration (x=120..600, y=210..440), pad to square, scale short side to 256, Wholesale gradient
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\Wholesale of Various Materials1.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
# TIGHTER crop on illustration only (no text, minimal padding)
[int]$x0 = 120; [int]$x1 = 600; [int]$y0 = 210; [int]$y1 = 440
[int]$cw = $x1 - $x0 + 1; [int]$ch = $y1 - $y0 + 1
Write-Output "Tight illustration: ${cw}x${ch}"
# Extract
$clean = New-Object System.Drawing.Bitmap($cw, $ch)
$g = [System.Drawing.Graphics]::FromImage($clean)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $cw, $ch)), (New-Object System.Drawing.Rectangle($x0, $y0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
# Pad to square (max dimension) - minimal padding
[int]$S = [Math]::Max($cw, $ch)
$padded = New-Object System.Drawing.Bitmap($S, $S)
$g2 = [System.Drawing.Graphics]::FromImage($padded)
$g2.Clear([System.Drawing.Color]::White)
[int]$dx = [int](($S - $cw) / 2)
[int]$dy = [int](($S - $ch) / 2)
$g2.DrawImage($clean, (New-Object System.Drawing.Rectangle($dx, $dy, $cw, $ch)))
$g2.Dispose()
# Scale to 256 max
[int]$nw = $S; [int]$nh = $S
if ($S -gt 256) {
  [double]$ratio = 256.0 / $S
  $nw = [int]([Math]::Round($S * $ratio))
  $nh = [int]([Math]::Round($S * $ratio))
}
$res = New-Object System.Drawing.Bitmap($nw, $nh)
$g3 = [System.Drawing.Graphics]::FromImage($res)
$g3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g3.DrawImage($padded, (New-Object System.Drawing.Rectangle(0, 0, $nw, $nh)))
$g3.Dispose()
# Wholesale gradient
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236
for ([int]$x = 0; $x -lt $nw; $x++) {
  for ([int]$y = 0; $y -lt $nh; $y++) {
    $c = $res.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    [int]$a = 255 - $lum
    if ($a -lt 30) { $a = 0 }
    [double]$t = $y / [double]$nh
    [int]$r = [int]($tR + (($bR - $tR) * $t))
    [int]$gg = [int]($tG + (($bG - $tG) * $t))
    [int]$b = [int]($tB + (($bB - $tB) * $t))
    $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
  }
}
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\wholesale-trading-large.png"
$res.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "wholesale-trading-large.png: ${nw}x${nh} ($([math]::Round((Get-Item $out).Length/1KB)) KB)"
$res.Dispose(); $padded.Dispose(); $clean.Dispose(); $img.Dispose(); $bmp.Dispose()