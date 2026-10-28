# Recolor European Timber Import with Teal gradient (Dark Teal #0f766e -> Light Teal #14b8a6)
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\european-timber-teal.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
[int]$tR = 15; [int]$tG = 118; [int]$tB = 110   # #0f766e (Dark Teal)
[int]$bR = 20; [int]$bG = 184; [int]$bB = 166   # #14b8a6 (Light Teal)
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
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "european-timber-teal.png: ${W}x${H}"
$bmp.Dispose(); $img.Dispose()