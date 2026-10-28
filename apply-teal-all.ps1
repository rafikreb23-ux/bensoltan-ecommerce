# Recolor all 3 service icons with Teal gradient (Dark Teal #0f766e -> Light Teal #14b8a6)
Add-Type -AssemblyName System.Drawing
$icons = @(
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-gradient.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-teal.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-teal.png" }
)
# Teal gradient: Dark Teal #0f766e -> Light Teal #14b8a6
[int]$tR = 15; [int]$tG = 118; [int]$tB = 110    # #0f766e
[int]$bR = 20; [int]$bG = 184; [int]$bB = 166    # #14b8a6
foreach ($icon in $icons) {
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
Write-Output "Done - all 3 recolored with Teal gradient"