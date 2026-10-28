# Recreate 6 feature icons with vibrant V2 blue gradient
Add-Type -AssemblyName System.Drawing

$icons = @(
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\certified-wood-blue.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\certified-wood-blue-v2.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-blue.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-blue-v2.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\prices-blue.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\prices-blue-v2.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\nationwide-delivery-blue.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\nationwide-delivery-blue-v2.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\free-consultation-blue.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\free-consultation-blue-v2.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\building-materials-blue.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\building-materials-blue-v2.png" }
)

# Vibrant V2 gradient: Dark Blue -> Site Blue -> Bright Blue
[int]$tR = 20; [int]$tG = 50; [int]$tB = 140      # Dark vibrant blue
[int]$mR = 30; [int]$mG = 64; [int]$mB = 175      # Site blue #1E40AF
[int]$bR = 60; [int]$bG = 140; [int]$bB = 255     # Bright blue #3C8CFF

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
          [int]$b = [int]($mB + (($mB - $mB) * $lt))
          $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
        }
      }
    }
  }
  $bmp.Save($icon.out, [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Output "$($icon.out): ${W}x${H}"
  $bmp.Dispose(); $img.Dispose()
}
Write-Output "All 6 feature icons recreated with vibrant V2 gradient"