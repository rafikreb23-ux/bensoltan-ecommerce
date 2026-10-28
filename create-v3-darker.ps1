# Create V3 darker versions for Wholesale and Fast Delivery
Add-Type -AssemblyName System.Drawing

$icons = @(
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue-v3.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue-v3.png" }
)

# DARKER gradient: Very dark blue -> Site Blue -> Medium blue (less bright)
[int]$tR = 10; [int]$tG = 25; [int]$tB = 80       # Very dark navy #0A1950
[int]$mR = 30; [int]$mG = 64; [int]$mB = 175      # Site blue #1E40AF
[int]$bR = 40; [int]$bG = 100; [int]$bB = 220     # Medium blue #2864DC (darker than before)

foreach ($icon in $icons) {
  $img = [System.Drawing.Image]::FromFile($icon.src)
  $bmp = New-Object System.Drawing.Bitmap($img)
  [int]$W = $img.Width; [int]$H = $img.Height
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
  $bmp.Save($icon.out, [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Output "$($icon.out): ${W}x${H}"
  $bmp.Dispose(); $img.Dispose()
}
Write-Output "Done - V3 darker versions created"