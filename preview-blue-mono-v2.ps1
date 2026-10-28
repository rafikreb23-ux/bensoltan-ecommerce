# Preview: True Monochromatic Blue Gradient (harmonizes with #1e40af + gray + white + black)
Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons\european-timber-import-v2.png"
$out = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets\european-timber-blue-mono.png"
$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width; [int]$H = $img.Height
# True monochromatic blue: Dark Navy -> Site Blue -> Light Blue
[int]$tR = 12; [int]$tG = 28; [int]$tB = 85       # #0C1C55 (Very dark blue, near black)
[int]$mR = 30; [int]$mG = 64; [int]$mB = 175      # #1E40AF (Site blue - MIDDLE)
[int]$bR = 96; [int]$bG = 165; [int]$bB = 250     # #60A5FA (Light blue)
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
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "european-timber-blue-mono.png: ${W}x${H}"
$bmp.Dispose(); $img.Dispose()