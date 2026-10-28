# Recreate Wholesale and Fast Delivery with line weight matching Stock icon
Add-Type -AssemblyName System.Drawing

# Stock source for reference line weight
$stockSrc = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-blue-v2.png"
$stockImg = [System.Drawing.Image]::FromFile($stockSrc)
$stockBmp = New-Object System.Drawing.Bitmap($stockImg)
[int]$sW = $stockImg.Width; [int]$sH = $stockImg.Height
[int]$sOp=0; $sEdge=0
for ($y=0;$y -lt $sH;$y++) { for ($x=0;$x -lt $sW;$x++) { $c=$stockBmp.GetPixel($x,$y); if ($c.A -gt 150) { $sOp++; $isEdge=$false; for ($dy=-1;$dy -le 1;$dy++) { for ($dx=-1;$dx -le 1;$dx++) { $nx=$x+$dx; $ny=$y+$dy; if ($nx -ge 0 -and $nx -lt $sW -and $ny -ge 0 -and $ny -lt $sH) { $nc=$stockBmp.GetPixel($nx,$ny); if ($nc.A -lt 150) { $isEdge=$true } } } }; if ($isEdge) { $sEdge++ } } } }
$stockRatio = $sEdge / $sOp
Write-Output "Stock ratio: $stockRatio"
$stockImg.Dispose(); $stockBmp.Dispose()

# Wholesale from original source (Wholesale of Various Materials1.png)
$whSrc = "C:\Users\PC\Desktop\New folder (3)\Wholesale of Various Materials1.png"
$whImg = [System.Drawing.Image]::FromFile($whSrc)
$whBmp = New-Object System.Drawing.Bitmap($whImg)
[int]$W = $whImg.Width; [int]$H = $whImg.Height
Write-Output "Wholesale source: ${W}x${H}"

# Process: white bg -> transparent, then thin lines, then blue gradient
[int]$tR = 10; [int]$tG = 25; [int]$tB = 80
[int]$mR = 30; [int]$mG = 64; [int]$mB = 175
[int]$bR = 40; [int]$bG = 100; [int]$bB = 220

$whRes = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $whBmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    [int]$a = 255 - $lum
    if ($a -lt 30) { $a = 0 }
    [double]$t = $y / [double]$H
    if ($t -lt 0.5) {
      [double]$lt = $t * 2
      [int]$r = [int]($tR + (($mR - $tR) * $lt))
      [int]$gg = [int]($tG + (($mG - $tG) * $lt))
      [int]$b = [int]($tB + (($mB - $tB) * $lt))
      $whRes.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
    } else {
      [double]$lt = ($t - 0.5) * 2
      [int]$r = [int]($mR + (($bR - $mR) * $lt))
      [int]$gg = [int]($mG + (($bG - $mG) * $lt))
      [int]$b = [int]($mB + (($mB - $mB) * $lt))
      $whRes.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
    }
  }
}
# Thin lines: morphological erosion to thin the lines
$thin = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 1; $x -lt $W-1; $x++) {
  for ([int]$y = 1; $y -lt $H-1; $y++) {
    $c = $whRes.GetPixel($x, $y)
    if ($c.A -gt 20) {
      # Check if pixel is on edge (has transparent neighbor)
      $isEdge = $false
      for ($dy=-1;$dy -le 1;$dy++) { for ($dx=-1;$dx -le 1;$dx++) { $nc=$whRes.GetPixel($x+$dx,$y+$dy); if ($nc.A -lt 20) { $isEdge=$true } } }
      if (-not $isEdge) {
        # Interior pixel - make more transparent to thin
        $newA = [int]($c.A * 0.7)
        $thin.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($newA, $c.R, $c.G, $c.B))
      } else {
        $thin.SetPixel($x, $y, $c)
      }
    } else {
      $thin.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    }
  }
}

# Crop and pad
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

[int]$S=[Math]::Max($cw,$ch)
$pad = New-Object System.Drawing.Bitmap($S,$S)
$g2=[System.Drawing.Graphics]::FromImage($pad)
[int]$dx=[int](($S-$cw)/2); [int]$dy=[int](($S-$ch)/2)
$g2.DrawImage($crop, (New-Object System.Drawing.Rectangle($dx,$dy,$cw,$ch)))
$g2.Dispose()

[int]$nw=$S; [int]$nh=$S
if ($S -gt 256) { [double]$r=256.0/$S; $nw=[int]([Math]::Round($S*$r)); $nh=[int]([Math]::Round($S*$r)) }
$final = New-Object System.Drawing.Bitmap($nw,$nh)
$g3=[System.Drawing.Graphics]::FromImage($final)
$g3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g3.DrawImage($pad, (New-Object System.Drawing.Rectangle(0,0,$nw,$nh)))
$g3.Dispose()

$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue-v4.png"
$final.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "wholesale-materials1-blue-v4.png: ${nw}x${nh}"
$final.Dispose(); $pad.Dispose(); $crop.Dispose(); $thin.Dispose(); $whRes.Dispose(); $whImg.Dispose(); $whBmp.Dispose()

# Fast Delivery from original source
$fdSrc = "C:\Users\PC\Desktop\New folder (3)\Fast & Reliable Delivery.jpg"
$fdImg = [System.Drawing.Image]::FromFile($fdSrc)
$fdBmp = New-Object System.Drawing.Bitmap($fdImg)
[int]$W = $fdImg.Width; [int]$H = $fdImg.Height
Write-Output "Fast Delivery source: ${W}x${H}"

$fdRes = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $fdBmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    [int]$a = 255 - $lum
    if ($a -lt 30) { $a = 0 }
    [double]$t = $y / [double]$H
    if ($t -lt 0.5) {
      [double]$lt = $t * 2
      [int]$r = [int]($tR + (($mR - $tR) * $lt))
      [int]$gg = [int]($tG + (($mG - $tG) * $lt))
      [int]$b = [int]($tB + (($mB - $tB) * $lt))
      $fdRes.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
    } else {
      [double]$lt = ($t - 0.5) * 2
      [int]$r = [int]($mR + (($bR - $mR) * $lt))
      [int]$gg = [int]($mG + (($bG - $mG) * $lt))
      [int]$b = [int]($mB + (($mB - $mB) * $lt))
      $fdRes.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $gg, $b))
    }
  }
}

# Thin lines
$thin = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 1; $x -lt $W-1; $x++) {
  for ([int]$y = 1; $y -lt $H-1; $y++) {
    $c = $fdRes.GetPixel($x, $y)
    if ($c.A -gt 20) {
      $isEdge = $false
      for ($dy=-1;$dy -le 1;$dy++) { for ($dx=-1;$dx -le 1;$dx++) { $nc=$fdRes.GetPixel($x+$dx,$y+$dy); if ($nc.A -lt 20) { $isEdge=$true } } }
      if (-not $isEdge) { $newA = [int]($c.A * 0.7); $thin.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($newA, $c.R, $c.G, $c.B)) }
      else { $thin.SetPixel($x, $y, $c) }
    } else { $thin.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0,0,0,0)) }
  }
}

[int]$x0=$W; [int]$x1=0; [int]$y0=$H; [int]$y1=0
for ([int]$x=0;$x -lt $W;$x++) { for ([int]$y=0;$y -lt $H;$y++) { if ($thin.GetPixel($x,$y).A -gt 20) { if ($x -lt $x0) {$x0=$x}; if ($x -gt $x1) {$x1=$x}; if ($y -lt $y0) {$y0=$y}; if ($y -gt $y1) {$y1=$y} } } }
$cx0=[Math]::Max(0,$x0-4); $cy0=[Math]::Max(0,$y0-4)
$cx1=[Math]::Min($W-1,$x1+4); $cy1=[Math]::Min($H-1,$y1+4)
[int]$cw=$cx1-$cx0+1; [int]$ch=$cy1-$cy0+1

$crop = New-Object System.Drawing.Bitmap($cw, $ch)
$g = [System.Drawing.Graphics]::FromImage($crop)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($thin, (New-Object System.Drawing.Rectangle(0,0,$cw,$ch)), (New-Object System.Drawing.Rectangle($cx0,$cy0,$cw,$ch)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

[int]$S=[Math]::Max($cw,$ch)
$pad = New-Object System.Drawing.Bitmap($S,$S)
$g2=[System.Drawing.Graphics]::FromImage($pad)
[int]$dx=[int](($S-$cw)/2); [int]$dy=[int](($S-$ch)/2)
$g2.DrawImage($crop, (New-Object System.Drawing.Rectangle($dx,$dy,$cw,$ch)))
$g2.Dispose()

[int]$nw=$S; [int]$nh=$S
if ($S -gt 256) { [double]$r=256.0/$S; $nw=[int]([Math]::Round($S*$r)); $nh=[int]([Math]::Round($S*$r)) }
$final = New-Object System.Drawing.Bitmap($nw,$nh)
$g3=[System.Drawing.Graphics]::FromImage($final)
$g3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g3.DrawImage($pad, (New-Object System.Drawing.Rectangle(0,0,$nw,$nh)))
$g3.Dispose()

$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue-v4.png"
$final.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "fast-delivery-blue-v4.png: ${nw}x${nh}"
$final.Dispose(); $pad.Dispose(); $crop.Dispose(); $thin.Dispose(); $fdRes.Dispose(); $fdImg.Dispose(); $fdBmp.Dispose()

Write-Output "Done - both recreated with thin line style"