# Preview: Monochromatic Blue Gradient (based on site blue #1e40af)
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\european-timber-blue-mono.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
# Monochromatic blue gradient: Darker site blue -> Site blue -> Lighter site blue
[int]$tR = 15; [int]$tG = 32; [int]$tB = 100      # #0F2064 (Darker than #1e40af)
[int]$mR = 30; [int]$mG = 64; [int]$mB = 175      # #1E40AF (Site blue - middle)
[int]$bR = 59; [int]$bG = 130; [int]$bB = 246     # #3B82F6 (Lighter blue)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    if ($c.A -gt 20) {
      [double]$t = $y / [double]$H
      # Three-stop gradient
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
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "european-timber-blue-mono.png: ${W}x${H}"
$bmp.Dispose(); $img.Dispose()