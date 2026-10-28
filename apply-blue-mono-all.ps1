# Apply Monochromatic Blue Gradient to ALL custom icons
Add-Type -AssemblyName System.Drawing
$icons = @(
  # Hero icons (index pages)
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\timber-import-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\timber-import-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\certified-wood-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\certified-wood-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\prices-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\prices-blue.png" },

  # Feature cards (index pages)
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\free-consultation-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\free-consultation-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\building-materials-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\building-materials-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\nationwide-delivery-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\nationwide-delivery-blue.png" },

  # Contact page
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\working-hours-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\working-hours-blue.png" },

  # About page team avatars
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\founder-v4.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\founder-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\team-of-professionals-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\team-of-professionals-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\broad-elite-specialists-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\broad-elite-specialists-blue.png" },

  # Service cards (already blue but update for consistency)
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-gradient.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-blue.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-blue.png" }
)

# Monochromatic Blue Gradient: Dark Navy #0C1C55 -> Site Blue #1E40AF -> Light Blue #60A5FA
[int]$tR = 12; [int]$tG = 28; [int]$tB = 85       # #0C1C55 (Dark Navy)
[int]$mR = 30; [int]$mG = 64; [int]$mB = 175      # #1E40AF (Site Blue - MIDDLE)
[int]$bR = 96; [int]$bG = 165; [int]$bB = 250     # #60A5FA (Light Blue)

foreach ($icon in $icons) {
  if (-not (Test-Path $icon.src)) {
    Write-Output "MISSING: $($icon.src)"
    continue
  }
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
Write-Output "Done - all icons recolored with Monochromatic Blue gradient"