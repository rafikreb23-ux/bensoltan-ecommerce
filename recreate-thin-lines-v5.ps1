# Recreate Wholesale and Fast Delivery with line weight matching Stock icon (ratio ~0.55-0.60)
Add-Type -AssemblyName System.Drawing

# Stock reference
$stockSrc = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-blue-v2.png"
$stockImg = [System.Drawing.Image]::FromFile($stockSrc)
$stockBmp = New-Object System.Drawing.Bitmap($stockImg)
[int]$sW = $stockImg.Width; [int]$sH = $stockImg.Height
[int]$sOp=0; $sEdge=0
for ($y=0;$y -lt $sH;$y+=2) { for ($x=0;$x -lt $sW;$x+=2) { $c=$stockBmp.GetPixel($x,$y); if ($c.A -gt 150) { $sOp++; $isEdge=$false; for ($dy=-1;$dy -le 1;$dy++) { for ($dx=-1;$dx -le 1;$dx++) { $nx=$x+$dx; $ny=$y+$dy; if ($nx -ge 0 -and $nx -lt $sW -and $ny -ge 0 -and $ny -lt $sH) { $nc=$stockBmp.GetPixel($nx,$ny); if ($nc.A -lt 150) { $isEdge=$true } } } }; if ($isEdge) { $sEdge++ } } } }
$stockRatio = $sEdge / $sOp
Write-Output "Target stock ratio: $stockRatio"
$stockImg.Dispose(); $stockBmp.Dispose()

# Process function
function Process-Icon {
  param($srcPath, $outPath, $erosionFactor)
  $img = [System.Drawing.Image]::FromFile($srcPath)
  $bmp = New-Object System.Drawing.Bitmap($img)
  [int]$W = $img.Width; [int]$H = $img.Height
  Write-Output "Source: ${W}x${H}"

  # Darker gradient
  [int]$tR = 10; [int]$tG = 25; [int]$tB = 80
  [int]$mR = 30; [int]$mG = 64; [int]$mB = 175
  [int]$bR = 40; [int]$bG = 100; [int]$bB = 220

  # Apply gradient with alpha from luminance
  $res = New-Object System.Drawing.Bitmap($W, $H)
  for ([int]$x = 0; $x -lt $W; $x++) {
    for ([int]$y = 0; $y -lt $H; $y++) {
      $c = $bmp.GetPixel($x, $y)
      [int]$lum = ($c.R + $c.G + $c.B) / 3
      [int]$a = 255 - $lum
      if ($a -lt 30) { $a = 0 }
      [double]$t = $y / [double]$H
      if ($t -lt 0.5) {
        [double]$lt = $t * 2
        [int]$r = [int]($tR + (($mR - $tR) * $lt))
        [int]$gg = [int]($tG + (($mG - $tG) * $lt))
        [int]$b = [int]($tB + (($mB - $tB) * $lt))
        $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
      } else {
        [double]$lt = ($t - 0.5) * 2
        [int]$r = [int]($mR + (($bR - $mR) * $lt))
        [int]$gg = [int]($tG + (($bG - $tG) * $lt))
        [int]$b = [int]($tB + (($bB - $mB) * $lt))
        $res.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
      }
    }
  }

  # Moderate thinning: only thin interior pixels slightly
  $thin = New-Object System.Drawing.Bitmap($W, $H)
  for ([int]$x = 1; $x -lt $W-1; $x++) {
    for ([int]$y = 1; $y -lt $H-1; $y++) {
      $c = $res.GetPixel($x, $y)
      if ($c.A -gt 20) {
        # Check if interior (all 8 neighbors opaque)
        $interior = $true
        for ($dy=-1;$dy -le 1;$dy++) { for ($dx=-1;$dx -le 1;$dx++) { if ($dx -ne 0 -or $dy -ne 0) { $nc=$res.GetPixel($x+$dx,$y+$dy); if ($nc.A -lt 20) { $interior=$false } } } }
        if ($interior) {
          $newA = [int]($c.A * $erosionFactor)
          $thin.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($newA, $c.R, $c.G, $c.B))
        } else {
          $thin.SetPixel($x, $y, $c)
        }
      } else { $thin.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0,0,0,0)) }
    }
  }

  # Crop
  [int]$x0=$W; [int]$x1=0; [int]$y0=$H; [int]$y1=0
  for ([int]$x=0;$x -lt $W;$x++) { for ([int]$y=0;$y -lt $H;$y++) { if ($thin.GetPixel($x,$y).A -gt 20) { if ($x -lt $x0) {$x0=$x}; if ($x -gt $x1) {$x1=$x}; if ($y -lt $y0) {$y0=$y}; if ($y -gt $y1) {$y1=$y} } } }
  [int]$m=4
  $cx0=[Math]::Max(0,$x0-$m); $cy0=[Math]::Max(0,$y0-$m)
  $cx1=[Math]::Min($W-1,$x1+$m); $cy1=[Math]::Min($H-1,$y1+$m)
  [int]$cw=$cx1-$cx0+1; [int]$ch=$cy1-$cy0+1

  $crop = New-Object System.Drawing.Bitmap($cw, $ch)
  $g = [System.Drawing.Graphics]::FromImage($crop)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($thin, (New-Object System.Drawing.Rectangle(0,0,$cw,$ch)), (New-Object System.Drawing.Rectangle($cx0,$cy0,$cw,$ch)), [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()

  # Pad to square
  [int]$S=[Math]::Max($cw,$ch)
  $pad = New-Object System.Drawing.Bitmap($S,$S)
  $g2=[System.Drawing.Graphics]::FromImage($pad)
  [int]$dx=[int](($S-$cw)/2); [int]$dy=[int](($S-$ch)/2)
  $g2.DrawImage($crop, (New-Object System.Drawing.Rectangle($dx,$dy,$cw,$ch)))
  $g2.Dispose()

  # Scale to 256
  [int]$nw=$S; [int]$nh=$S
  if ($S -gt 256) { [double]$r=256.0/$S; $nw=[int]([Math]::Round($S*$r)); $nh=[int]([Math]::Round($S*$r)) }
  $final = New-Object System.Drawing.Bitmap($nw,$nh)
  $g3=[System.Drawing.Graphics]::FromImage($final)
  $g3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g3.DrawImage($pad, (New-Object System.Drawing.Rectangle(0,0,$nw,$nh)))
  $g3.Dispose()

  $final.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Output "$outPath: ${nw}x${nh}"
  $final.Dispose(); $pad.Dispose(); $crop.Dispose(); $thin.Dispose(); $res.Dispose(); $img.Dispose(); $bmp.Dispose()
}

# Wholesale - try erosion factor 0.85 (moderate)
Process-Icon "C:\Users\PC\Desktop\New folder (3)\Wholesale of Various Materials1.png" "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue-v5.png" 0.85

# Fast Delivery
Process-Icon "C:\Users\PC\Desktop\New folder (3)\Fast & Reliable Delivery.jpg" "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue-v5.png" 0.85

Write-Output "Done"