# Recolor Founder & CEO with Wholesale gradient (purple #C146F7 top -> blue #6D92EC bottom)
# Preserve alpha + preserve white stroke details, content-crop, max 256px
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\Founder & CEO.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height
# content bbox
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
$resized = New-Object System.Drawing.Bitmap($nw, $nh)
$g = [System.Drawing.Graphics]::FromImage($resized)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $nw, $nh)), (New-Object System.Drawing.Rectangle($cx0, $cy0, $cw, $ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
# recolor non-white pixels with vertical gradient, keep alpha, keep white details
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247   # top purple #C146F7
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236  # bottom blue #6D92EC
[int]$whiteKept = 0; [int]$grad = 0
for ([int]$x = 0; $x -lt $nw; $x++) {
  for ([int]$y = 0; $y -lt $nh; $y++) {
    $c = $resized.GetPixel($x, $y)
    if ($c.A -gt 20) {
      if (($c.R -gt 200) -and ($c.G -gt 200) -and ($c.B -gt 200)) {
        $whiteKept++   # keep white stroke details as-is
      } else {
        [double]$t = $y / [double]$nh
        [int]$r = [int]($tR + (($bR - $tR) * $t))
        [int]$gg = [int]($tG + (($bG - $tG) * $t))
        [int]$b = [int]($tB + (($bB - $tB) * $t))
        $resized.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
        $grad++
      }
    }
  }
}
$resized.Save("C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\founder-v3.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "founder-v3.png: ${nw}x${nh} | gradient pixels: $grad | white details kept: $whiteKept"
$resized.Dispose(); $img.Dispose(); $bmp.Dispose()
