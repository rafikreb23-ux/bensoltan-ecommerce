# European Timber Import.jpg -> european-timber-import-v2.png
# Use ONLY the cabin: crop the white line-art house, drop the teal background, Wholesale gradient, max 256
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\European Timber Import.jpg"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
# background luminance from corner
$bg = $bmp.GetPixel(2, 2)
[int]$bgLum = ($bg.R + $bg.G + $bg.B) / 3
Write-Output "Source ${W}x${H} | bg RGB($($bg.R),$($bg.G),$($bg.B)) lum=$bgLum"
[int]$thr = $bgLum + 40
[int]$x0 = $W; [int]$x1 = 0; [int]$y0 = $H; [int]$y1 = 0
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    if ($lum -gt $thr) {
      if ($x -lt $x0) { $x0 = $x }; if ($x -gt $x1) { $x1 = $x }
      if ($y -lt $y0) { $y0 = $y }; if ($y -gt $y1) { $y1 = $y }
    }
  }
}
[int]$cw = $x1 - $x0 + 1; [int]$ch = $y1 - $y0 + 1
[int]$m = [int]([Math]::Max($cw, $ch) * 0.03)
$cx0 = [Math]::Max(0, $x0 - $m); $cy0 = [Math]::Max(0, $y0 - $m)
$cx1 = [Math]::Min($W - 1, $x1 + $m); $cy1 = [Math]::Min($H - 1, $y1 + $m)
[int]$pw = $cx1 - $cx0 + 1; [int]$ph = $cy1 - $cy0 + 1
Write-Output "Cabin bbox: ($x0,$y0)-($x1,$y1) => ${cw}x${ch} | crop ${pw}x${ph}"
[int]$nw = $pw; [int]$nh = $ph
if (($pw -gt 256) -or ($ph -gt 256)) {
  [double]$ratio = 256 / [Math]::Max($pw, $ph)
  $nw = [int]([Math]::Round($pw * $ratio)); $nh = [int]([Math]::Round($ph * $ratio))
}
$res = New-Object System.Drawing.Bitmap($nw, $nh)
$g = [System.Drawing.Graphics]::FromImage($res)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $nw, $nh)), (New-Object System.Drawing.Rectangle($cx0, $cy0, $pw, $ph)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
# alpha from brightness (white cabin lines opaque, teal bg transparent) + Wholesale gradient colors
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236
for ([int]$x = 0; $x -lt $nw; $x++) {
  for ([int]$y = 0; $y -lt $nh; $y++) {
    $c = $res.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    [int]$a = [int](($lum - $bgLum) * 255 / [Math]::Max(1, (255 - $bgLum)))
    if ($a -lt 20) { $a = 0 }
    if ($a -gt 255) { $a = 255 }
    [double]$t = $y / [double]$nh
    [int]$r = [int]($tR + (($bR - $tR) * $t))
    [int]$gg = [int]($tG + (($bG - $tG) * $t))
    [int]$b = [int]($tB + (($bB - $tB) * $t))
    $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
  }
}
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"
$res.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "european-timber-import-v2.png: ${nw}x${nh} ($([math]::Round((Get-Item $out).Length/1KB)) KB)"
$res.Dispose(); $img.Dispose(); $bmp.Dispose()
