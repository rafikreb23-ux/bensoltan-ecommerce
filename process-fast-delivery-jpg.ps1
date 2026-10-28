# Fast & Reliable Delivery.jpg -> fast-delivery-v3.png
# Wholesale gradient + crop white bg to transparent, max 256
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\Fast & Reliable Delivery.jpg"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
[int]$x0 = $W; [int]$x1 = 0; [int]$y0 = $H; [int]$y1 = 0
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    if ((255 - $lum) -gt 20) {
      if ($x -lt $x0) { $x0 = $x }; if ($x -gt $x1) { $x1 = $x }
      if ($y -lt $y0) { $y0 = $y }; if ($y -gt $y1) { $y1 = $y }
    }
  }
}
[int]$m = 6
$cx0 = [Math]::Max(0, $x0 - $m); $cy0 = [Math]::Max(0, $y0 - $m)
$cx1 = [Math]::Min($W - 1, $x1 + $m); $cy1 = [Math]::Min($H - 1, $y1 + $m)
[int]$cw = $cx1 - $cx0 + 1; [int]$ch = $cy1 - $cy0 + 1
[int]$nw = $cw; [int]$nh = $ch
if (($cw -gt 256) -or ($ch -gt 256)) {
  [double]$ratio = 256 / [Math]::Max($cw, $ch)
  $nw = [int]([Math]::Round($cw * $ratio)); $nh = [int]([Math]::Round($ch * $ratio))
}
$res = New-Object System.Drawing.Bitmap($nw, $nh)
$g = [System.Drawing.Graphics]::FromImage($res)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $nw, $nh)), (New-Object System.Drawing.Rectangle($cx0, $cy0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
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
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-v3.png"
$res.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "fast-delivery-v3.png: ${nw}x${nh} ($([math]::Round((Get-Item $out).Length/1KB)) KB)"
$res.Dispose(); $img.Dispose(); $bmp.Dispose()