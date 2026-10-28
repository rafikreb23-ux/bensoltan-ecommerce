# Recreate wholesale and fast-delivery with MORE VIBRANT blue gradient
Add-Type -AssemblyName System.Drawing

# Wholesale - use source image
$src = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height

# MORE VIBRANT: Dark Blue -> Site Blue -> Bright Blue
[int]$tR = 20; [int]$tG = 50; [int]$tB = 140      # Dark vibrant blue
[int]$mR = 30; [int]$mG = 64; [int]$mB = 175      # Site blue #1E40AF
[int]$bR = 60; [int]$bG = 140; [int]$bB = 255     # Bright blue #3C8CFF

for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$H
      if ($t -lt 0.5) {
        [double]$lt = $t * 2
        [int]$r = [int]($tR + (($mR - $tR) * $lt))
        [int]$gg = [int]($tG + (($mG - $tG) * $lt))
        [int]$b = [int]($tB + (($mB - $tB) * $lt))
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      } else {
        [double]$lt = ($t - 0.5) * 2
        [int]$r = [int]($mR + (($bR - $mR) * $lt))
        [int]$gg = [int]($mG + (($bG - $mG) * $lt))
        [int]$b = [int]($mB + (($bB - $mB) * $lt))
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
}
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue-v2.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "wholesale-materials1-blue-v2.png: ${W}x${H}"
$bmp.Dispose(); $img.Dispose()

# Fast delivery - use source
$src2 = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue.png"
$img2 = [System.Drawing.Image]::FromFile($src2)
$bmp2 = New-Object System.Drawing.Bitmap($img2)
[int]$W2 = $img2.Width; [int]$H2 = $img2.Height

for ([int]$x = 0; $x -lt $W2; $x++) {
  for ([int]$y = 0; $y -lt $H2; $y++) {
    $c = $bmp2.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$H2
      if ($t -lt 0.5) {
        [double]$lt = $t * 2
        [int]$r = [int]($tR + (($mR - $tR) * $lt))
        [int]$gg = [int]($tG + (($mG - $tG) * $lt))
        [int]$b = [int]($tB + (($mB - $tB) * $lt))
        $bmp2.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      } else {
        [double]$lt = ($t - 0.5) * 2
        [int]$r = [int]($mR + (($bR - $mR) * $lt))
        [int]$gg = [int]($mG + (($bG - $mG) * $lt))
        [int]$b = [int]($mB + (($bB - $mB) * $lt))
        $bmp2.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
}
$out2 = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue-v2.png"
$bmp2.Save($out2, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "fast-delivery-blue-v2.png: ${W2}x${H2}"
$bmp2.Dispose(); $img2.Dispose()

# Also recreate team avatars and working hours with VIBRANT blue to ensure no green/cache
# Founder
$src3 = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\founder-blue.png"
$img3 = [System.Drawing.Image]::FromFile($src3)
$bmp3 = New-Object System.Drawing.Bitmap($img3)
[int]$W3 = $img3.Width; [int]$H3 = $img3.Height
for ([int]$x = 0; $x -lt $W3; $x++) {
  for ([int]$y = 0; $y -lt $H3; $y++) {
    $c = $bmp3.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$H3
      if ($t -lt 0.5) {
        [double]$lt = $t * 2
        [int]$r = [int]($tR + (($mR - $tR) * $lt))
        [int]$gg = [int]($tG + (($mG - $tG) * $lt))
        [int]$b = [int]($tB + (($mB - $tB) * $lt))
        $bmp3.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      } else {
        [double]$lt = ($t - 0.5) * 2
        [int]$r = [int]($mR + (($bR - $mR) * $lt))
        [int]$gg = [int]($mG + (($bG - $mG) * $lt))
        [int]$b = [int]($mB + (($mB - $mB) * $lt))
        $bmp3.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
}
$bmp3.Save("C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\founder-blue-v2.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "founder-blue-v2.png: ${W3}x${H3}"
$bmp3.Dispose(); $img3.Dispose()

# Team of professionals
$src4 = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\team-of-professionals-blue.png"
$img4 = [System.Drawing.Image]::FromFile($src4)
$bmp4 = New-Object System.Drawing.Bitmap($img4)
[int]$W4 = $img4.Width; [int]$H4 = $img4.Height
for ([int]$x = 0; $x -lt $W4; $x++) {
  for ([int]$y = 0; $y -lt $H4; $y++) {
    $c = $bmp4.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$H4
      if ($t -lt 0.5) {
        [double]$lt = $t * 2
        [int]$r = [int]($tR + (($mR - $tR) * $lt))
        [int]$gg = [int]($tG + (($mG - $tG) * $lt))
        [int]$b = [int]($tB + (($mB - $tB) * $lt))
        $bmp4.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      } else {
        [double]$lt = ($t - 0.5) * 2
        [int]$r = [int]($mR + (($bR - $mR) * $lt))
        [int]$gg = [int]($mG + (($bG - $mG) * $lt))
        [int]$b = [int]($mB + (($mB - $mB) * $lt))
        $bmp4.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
}
$bmp4.Save("C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\team-of-professionals-blue-v2.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "team-of-professionals-blue-v2.png: ${W4}x${H4}"
$bmp4.Dispose(); $img4.Dispose()

# Broad elite specialists
$src5 = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\broad-elite-specialists-blue.png"
$img5 = [System.Drawing.Image]::FromFile($src5)
$bmp5 = New-Object System.Drawing.Bitmap($img5)
[int]$W5 = $img5.Width; [int]$H5 = $img5.Height
for ([int]$x = 0; $x -lt $W5; $x++) {
  for ([int]$y = 0; $y -lt $H5; $y++) {
    $c = $bmp5.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$H5
      if ($t -lt 0.5) {
        [double]$lt = $t * 2
        [int]$r = [int]($tR + (($mR - $tR) * $lt))
        [int]$gg = [int]($tG + (($mG - $tG) * $lt))
        [int]$b = [int]($tB + (($mB - $tB) * $lt))
        $bmp5.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      } else {
        [double]$lt = ($t - 0.5) * 2
        [int]$r = [int]($mR + (($bR - $mR) * $lt))
        [int]$gg = [int]($mG + (($bG - $mG) * $lt))
        [int]$b = [int]($mB + (($mB - $mB) * $lt))
        $bmp5.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
}
$bmp5.Save("C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\broad-elite-specialists-blue-v2.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "broad-elite-specialists-blue-v2.png: ${W5}x${H5}"
$bmp5.Dispose(); $img5.Dispose()

# Working hours
$src6 = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\working-hours-blue.png"
$img6 = [System.Drawing.Image]::FromFile($src6)
$bmp6 = New-Object System.Drawing.Bitmap($img6)
[int]$W6 = $img6.Width; [int]$H6 = $img6.Height
for ([int]$x = 0; $x -lt $W6; $x++) {
  for ([int]$y = 0; $y -lt $H6; $y++) {
    $c = $bmp6.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$H6
      if ($t -lt 0.5) {
        [double]$lt = $t * 2
        [int]$r = [int]($tR + (($mR - $tR) * $lt))
        [int]$gg = [int]($tG + (($mG - $tG) * $lt))
        [int]$b = [int]($tB + (($mB - $tB) * $lt))
        $bmp6.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      } else {
        [double]$lt = ($t - 0.5) * 2
        [int]$r = [int]($mR + (($bR - $mR) * $lt))
        [int]$gg = [int]($mG + (($bG - $mG) * $lt))
        [int]$b = [int]($mB + (($mB - $mB) * $lt))
        $bmp6.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
}
$bmp6.Save("C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\working-hours-blue-v2.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "working-hours-blue-v2.png: ${W6}x${H6}"
$bmp6.Dispose(); $img6.Dispose()

Write-Output "All V2 icons created with vibrant blue gradient"