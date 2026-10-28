# Apply Teal gradient to ALL custom icons
Add-Type -AssemblyName System.Drawing
$icons = @(
  # Hero icons (index pages)
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\timber-import-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\timber-import-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\certified-wood-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\certified-wood-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\stock-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\prices-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\prices-teal.png" },

  # Feature cards (index pages)
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\free-consultation-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\free-consultation-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\building-materials-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\building-materials-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\nationwide-delivery-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\nationwide-delivery-teal.png" },

  # Contact page
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\working-hours-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\working-hours-teal.png" },

  # About page team avatars
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\founder-v4.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\founder-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\team-of-professionals-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\team-of-professionals-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\broad-elite-specialists-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\broad-elite-specialists-teal.png" }
)

# Teal gradient: Dark Teal #0f766e -> Light Teal #14b8a6
[int]$tR = 15; [int]$tG = 118; [int]$tB = 110    # #0f766e
[int]$bR = 20; [int]$bG = 184; [int]$bB = 166    # #14b8a6

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
        [int]$r = [int]($tR + (($bR - $tR) * $t))
        [int]$gg = [int]($tG + (($bG - $tG) * $t))
        [int]$b = [int]($tB + (($bB - $tB) * $t))
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $gg, $b))
      }
    }
  }
  $bmp.Save($icon.out, [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Output "$($icon.out): ${W}x${H}"
  $bmp.Dispose(); $img.Dispose()
}
Write-Output "Done - all icons recolored with Teal gradient"