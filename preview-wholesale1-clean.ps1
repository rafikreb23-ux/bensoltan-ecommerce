# Wholesale of Various Materials1.jpg -> wholesale1-clean.png
# Crop to clean illustration only (exclude top text y<200, right text x>500), Wholesale gradient, max 256, fill frame well
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\Wholesale of Various Materials1.jpg"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
# Clean region: y=200..500, x=100..500 (avoid top text, right edge text)
[int]$y0 = 200; [int]$y1 = 500
[int]$x0 = 100; [int]$x1 = 500
[int]$cw = $x1 - $x0 + 1; [int]$ch = $y1 - $y0 + 1
Write-Output "Clean crop region: ($x0,$y0)-($x1,$y1) => ${cw}x${ch}"
[int]$m = 10
$cx0 = [Math]::Max(0, $x0 - $m); $cy0 = [Math]::Max(0, $y0 - $m)
$cx1 = [Math]::Min($W - 1, $x1 + $m); $cy1 = [Math]::Min($H - 1, $y1 + $m)
[int]$pcw = $cx1 - $cx0 + 1; [int]$pch = $cy1 - $cy0 + 1
[int]$nw = $pcw; [int]$nh = $pch
if (($pcw -gt 256) -or ($pch -gt 256)) {
  [double]$ratio = 256 / [Math]::Max($pcw, $pch)
  $nw = [int]([Math]::Round($pcw * $ratio)); $nh = [int]([Math]::Round($pch * $ratio))
}
$res = New-Object System.Drawing.Bitmap($nw, $nh)
$g = [System.Drawing.Graphics]::FromImage($res)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $nw, $nh)), (New-Object System.Drawing.Rectangle($cx0, $cy0, $pcw, $pch)), [System.Drawing.GraphicsUnit]::Pixel)
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
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\wholesale1-clean-gradient.png"
$res.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Clean preview saved: ${nw}x${nh} ($([math]::Round((Get-Item $out).Length/1KB)) KB)"
$res.Dispose(); $img.Dispose(); $bmp.Dispose()