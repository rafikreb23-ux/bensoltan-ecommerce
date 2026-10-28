# working-hours.png -> working-hours-v2.png : content-crop, max 256, Wholesale gradient (purple->blue), alpha preserved
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\working-hours.png"
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
Write-Output "Source: ${W}x${H} | content bbox: ($x0,$y0)-($x1,$y1)"
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
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247    # top purple #C146F7
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236   # bottom blue #6D92EC
[int]$white = 0; [int]$grad = 0
for ([int]$x = 0; $x -lt $nw; $x++) {
  for ([int]$y = 0; $y -lt $nh; $y++) {
    $c = $res.GetPixel($x, $y)
    if ($c.A -gt 20) {
      if (($c.R -gt 200) -and ($c.G -gt 200) -and ($c.B -gt 200)) { $white++ }
      else {
        [double]$t = $y / [double]$nh
        [int]$r = [int]($tR + (($bR - $tR) * $t))
        [int]$gg = [int]($tG + (($bG - $tG) * $t))
        [int]$b = [int]($tB + (($bB - $tB) * $t))
        $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
        $grad++
      }
    }
  }
}
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\working-hours-v2.png"
$res.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "working-hours-v2.png: ${nw}x${nh} ($([math]::Round((Get-Item $out).Length/1KB)) KB) | gradient px: $grad | white kept: $white"
$res.Dispose(); $img.Dispose(); $bmp.Dispose()
