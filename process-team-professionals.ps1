# A Complete Team of Professionals.png -> team-of-professionals-v2.png
# Wholesale gradient + circle-safe padding (content fits inside the 80px .team-avatar frame)
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\A Complete Team of Professionals.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
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
# Wholesale gradient (purple top -> blue bottom), alpha preserved, white details kept
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236
for ([int]$x = 0; $x -lt $nw; $x++) {
  for ([int]$y = 0; $y -lt $nh; $y++) {
    $c = $res.GetPixel($x, $y)
    if ($c.A -gt 20) {
      if (-not ((($c.R -gt 200) -and ($c.G -gt 200) -and ($c.B -gt 200)))) {
        [double]$t = $y / [double]$nh
        [int]$r = [int]($tR + (($bR - $tR) * $t))
        [int]$gg = [int]($tG + (($bG - $tG) * $t))
        [int]$b = [int]($tB + (($bB - $tB) * $t))
        $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
}
# max reach from center
[double]$cx = ($nw - 1) / 2; [double]$cy = ($nh - 1) / 2
[double]$maxR = 0
for ([int]$x = 0; $x -lt $nw; $x++) {
  for ([int]$y = 0; $y -lt $nh; $y++) {
    if ($res.GetPixel($x, $y).A -gt 60) {
      [double]$r = [Math]::Sqrt([Math]::Pow(($x - $cx), 2) + [Math]::Pow(($y - $cy), 2))
      if ($r -gt $maxR) { $maxR = $r }
    }
  }
}
[int]$S = [int][Math]::Ceiling(2 * $maxR * 1.05)
$canvas = New-Object System.Drawing.Bitmap($S, $S)
$g2 = [System.Drawing.Graphics]::FromImage($canvas)
$g2.DrawImage($res, (New-Object System.Drawing.Rectangle([int](($S - $nw) / 2), [int](($S - $nh) / 2), $nw, $nh)))
$g2.Dispose()
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\team-of-professionals-v2.png"
$canvas.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "team-of-professionals-v2.png: ${S}x${S} canvas (content ${nw}x${nh}, $([math]::Round((Get-Item $out).Length/1KB)) KB)"
Write-Output "Max reach: $([math]::Round($maxR,1))px -> at 80px frame: $([math]::Round($maxR*80/$S,1))px vs radius 40px => $(if ($maxR*80/$S -lt 40) {'FITS INSIDE'} else {'OVERFLOWS'})"
$canvas.Dispose(); $res.Dispose(); $img.Dispose(); $bmp.Dispose()
