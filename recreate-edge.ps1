# Recreate using edge detection (Sobel) to extract lines like stock icon
Add-Type -AssemblyName System.Drawing

function Process-Icon($srcPath, $outPath) {
  $img = [System.Drawing.Image]::FromFile($srcPath)
  $bmp = New-Object System.Drawing.Bitmap($img)
  [int]$W = $img.Width; [int]$H = $img.Height
  Write-Output "Source: ${W}x${H}"

  # Convert to grayscale
  $gray = New-Object System.Drawing.Bitmap($W, $H)
  for ($x=0;$x -lt $W;$x++) { for ($y=0;$y -lt $H;$y++) { $c=$bmp.GetPixel($x,$y); $lum=[int](($c.R+$c.G+$c.B)/3); $gray.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$lum,$lum,$lum)) } }

  # Sobel edge detection
  $edges = New-Object System.Drawing.Bitmap($W, $H)
  $sobelX = @(@(-1,0,1), @(-2,0,2), @(-1,0,1))
  $sobelY = @(@(-1,-2,-1), @(0,0,0), @(1,2,1))
  
  for ($x=1;$x -lt ($W-1);$x++) {
    for ($y=1;$y -lt ($H-1);$y++) {
      $gx=0; $gy=0
      for ($dy=-1;$dy -le 1;$dy++) {
        for ($dx=-1;$dx -le 1;$dx++) {
          $c = $gray.GetPixel($x+$dx, $y+$dy)
          $val = $c.R
          $gx += $val * $sobelX[$dy+1][$dx+1]
          $gy += $val * $sobelY[$dy+1][$dx+1]
        }
      }
      $mag = [Math]::Sqrt($gx*$gx + $gy*$gy)
      if ($mag -gt 50) { $edges.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,255,255,255)) }
      else { $edges.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(0,0,0,0)) }
    }
  }

  # Dilate edges slightly to make lines visible
  $dilated = New-Object System.Drawing.Bitmap($W, $H)
  for ($x=1;$x -lt ($W-1);$x++) {
    for ($y=1;$y -lt ($H-1);$y++) {
      $hasEdge = $false
      for ($dy=-1;$dy -le 1;$dy++) { for ($dx=-1;$dx -le 1;$dx++) { $c=$edges.GetPixel($x+$dx,$y+$dy); if ($c.A -gt 0) { $hasEdge=$true } } }
      if ($hasEdge) { $dilated.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,255,255,255)) }
      else { $dilated.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(0,0,0,0)) }
    }
  }

  # Apply blue gradient to edges
  [int]$tR = 10; [int]$tG = 25; [int]$tB = 80
  [int]$mR = 30; [int]$mG = 64; [int]$mB = 175
  [int]$bR = 40; [int]$bG = 100; [int]$bB = 220

  $final = New-Object System.Drawing.Bitmap($W, $H)
  for ($x=0;$x -lt $W;$x++) {
    for ($y=0;$y -lt $H;$y++) {
      if ($dilated.GetPixel($x,$y).A -gt 0) {
        [double]$t = $y / [double]$H
        if ($t -lt 0.5) {
          [double]$lt = $t * 2
          [int]$r = [int]($tR + (($mR - $tR) * $lt))
          [int]$gg = [int]($tG + (($mG - $tG) * $lt))
          [int]$b = [int]($tB + (($mB - $tB) * $lt))
          $final.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$r,$gg,$b))
        } else {
          [double]$lt = ($t - 0.5) * 2
          [int]$r = [int]($mR + (($bR - $mR) * $lt))
          [int]$gg = [int]($tG + (($bG - $tG) * $lt))
          [int]$b = [int]($tB + (($mB - $mB) * $lt))
          $final.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$r,$gg,$b))
        }
      } else { $final.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(0,0,0,0)) }
    }
  }

  # Crop to content
  [int]$x0=$W; [int]$x1=0; [int]$y0=$H; [int]$y1=0
  for ($x=0;$x -lt $W;$x++) { for ($y=0;$y -lt $H;$y++) { if ($final.GetPixel($x,$y).A -gt 0) { if ($x -lt $x0) {$x0=$x}; if ($x -gt $x1) {$x1=$x}; if ($y -lt $y0) {$y0=$y}; if ($y -gt $y1) {$y1=$y} } } }
  [int]$m=8
  $cx0=[Math]::Max(0,$x0-$m); $cy0=[Math]::Max(0,$y0-$m)
  $cx1=[Math]::Min($W-1,$x1+$m); $cy1=[Math]::Min($H-1,$y1+$m)
  [int]$cw=$cx1-$cx0+1; [int]$ch=$cy1-$cy0+1

  $crop = New-Object System.Drawing.Bitmap($cw, $ch)
  $g = [System.Drawing.Graphics]::FromImage($crop)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($final, (New-Object System.Drawing.Rectangle(0,0,$cw,$ch)), (New-Object System.Drawing.Rectangle($cx0,$cy0,$cw,$ch)), [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()

  # Pad to square
  [int]$S=[Math]::Max($cw,$ch)
  $pad = New-Object System.Drawing.Bitmap($S,$S)
  $g2=[System.Drawing.Graphics]::FromImage($pad)
  [int]$dx=[int](($S-$cw)/2); [int]$dy=[int](($S-$ch)/2)
  $g2.DrawImage($crop, (New-Object System.Drawing.Rectangle([int]$dx,[int]$dy,$cw,$ch)))
  $g2.Dispose()

  # Scale to 256
  [int]$nw=$S; [int]$nh=$S
  if ($S -gt 256) { [double]$r=256.0/$S; $nw=[int]([Math]::Round($S*$r)); $nh=[int]([Math]::Round($S*$r)) }
  $final2 = New-Object System.Drawing.Bitmap($nw,$nh)
  $g3=[System.Drawing.Graphics]::FromImage($final2)
  $g3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g3.DrawImage($pad, (New-Object System.Drawing.Rectangle(0,0,$nw,$nh)))
  $g3.Dispose()

  $final2.Save($args[1], [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Output "Saved: $args[1] ${nw}x${nh}"
}

Write-Output "Processing Wholesale..."
Process-Icon "C:\Users\PC\Desktop\New folder (3)\Wholesale of Various Materials1.png" "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue-v7.png"

Write-Output "Processing Fast Delivery..."
Process-Icon "C:\Users\PC\Desktop\New folder (3)\Fast & Reliable Delivery.jpg" "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue-v7.png"

Write-Output "Done"