# Wholesale of Various Materials1.png (YOUR cleaned file) -> wholesale-materials1-gradient.png
# Apply Wholesale gradient, pad to square, max 256, use alpha from YOUR cleaned file
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\Wholesale of Various Materials1.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
Write-Output "Source: ${W}x${H}"
# Find content bounds (alpha > 20)
[int]$x0 = $W; [int]$x1 = 0; [int]$y0 = $H; [int]$y1 = 0
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    if ($bmp.GetPixel($x, $y).A -gt 20) {
      if ($x -lt $x0) { $x0 = $x }; if ($x -gt $x1) { $x1 = $x }
      if ($y -lt $y0) { $y0 = $y }; if ($y -gt $y1) { $y1 = $y }
    }
  }
}
[int]$m = 4
$cx0 = [Math]::Max(0, $x0 - $m); $cy0 = [Math]::Max(0, $y0 - $m)
$cx1 = [Math]::Min($W - 1, $x1 + $m); $cy1 = [Math]::Min($H - 1, $y1 + $m)
[int]$cw = $cx1 - $cx0 + 1; [int]$ch = $cy1 - $cy0 + 1
Write-Output "Content bbox: ($cx0,$cy0)-($cx1,$cy1) => ${cw}x${ch}"
# Extract clean region preserving YOUR alpha
$clean = New-Object System.Drawing.Bitmap($cw, $ch)
$g = [System.Drawing.Graphics]::FromImage($clean)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $cw, $ch)), (New-Object System.Drawing.Rectangle($cx0, $cy0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
# Pad to square
[int]$S = [Math]::Max($cw, $ch)
$padded = New-Object System.Drawing.Bitmap($S, $S)
$g2 = [System.Drawing.Graphics]::FromImage($padded)
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
# Apply Wholesale gradient: preserve YOUR alpha, recolor non-transparent pixels
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236
for ([int]$x = 0; $x -lt $nw; $x++) {
  for ([int]$y = 0; $y -lt $nh; $y++) {
    $c = $res.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$nh
      [int]$r = [int]($tR + (($bR - $tR) * $t))
      [int]$gg = [int]($tG + (($bG - $tG) * $t))
      [int]$b = [int]($tB + (($bB - $tB) * $t))
      $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
    }
  }
}
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\wholesale-materials1-gradient.png"
$res.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "wholesale-materials1-gradient.png: ${nw}x${nh} ($([math]::Round((Get-Item $out).Length/1KB)) KB)"
$res.Dispose(); $padded.Dispose(); $clean.Dispose(); $img.Dispose(); $bmp.Dispose()