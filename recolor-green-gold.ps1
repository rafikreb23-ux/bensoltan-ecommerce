# Recolor all 3 service icons with Forest Green #166534 -> Amber Gold #D97706 gradient
Add-Type -AssemblyName System.Drawing
$icons = @(
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\european-timber-green-gold.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-gradient.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\wholesale-green-gold.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\fast-delivery-green-gold.png" }
)
# Forest Green -> Amber Gold
[int]$tR = 22; [int]$tG = 101; [int]$tB = 52     # #166534
[int]$bR = 217; [int]$bG = 119; [int]$bB = 6      # #D97706
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
Write-Output "Done - all 3 recolored with Forest Green -> Amber Gold"