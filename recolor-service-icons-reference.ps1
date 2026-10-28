# Recolor all 3 service icons with reference.jpg gradient (slate blue #5E7690 -> warm beige #8E7A5F)
Add-Type -AssemblyName System.Drawing
$icons = @(
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\european-timber-ref-gradient.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\wholesale-materials1-gradient.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\wholesale-ref-gradient.png" },
  @{ src="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\fast-delivery-v3.png"; out="C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\fast-delivery-ref-gradient.png" }
)
# Reference gradient: slate blue #5E7690 (top) -> warm beige #8E7A5F (bottom)
[int]$tR = 94; [int]$tG = 118; [int]$tB = 144   # #5E7690
[int]$bR = 142; [int]$bG = 122; [int]$bB = 95   # #8E7A5F
foreach ($icon in $icons) {
  $img = [System.Drawing.Image]::FromFile($icon.src)
  $bmp = New-Object System.Drawing.Bitmap($img)
  [int]$W = $img.Width; [int]$H = $img.Height
  # Recolor preserving alpha
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
Write-Output "Done - all 3 recolored with reference gradient"