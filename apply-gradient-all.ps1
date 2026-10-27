# Apply Wholesale gradient (purple #C146F7 top -> blue #6D92EC bottom) to all custom icon PNGs
Add-Type -AssemblyName System.Drawing
$dir = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\public\images\icons"
$files = @("timber-import.png", "wholesale.png", "certified-wood.png", "stock.png", "prices.png")
[int]$tR = 193; [int]$tG = 70; [int]$tB = 247   # top: purple #C146F7
[int]$bR = 109; [int]$bG = 146; [int]$bB = 236  # bottom: blue #6D92EC

foreach ($f in $files) {
  $p = Join-Path $dir $f
  $img = [System.Drawing.Image]::FromFile($p)
  $bmp = New-Object System.Drawing.Bitmap($img)
  [int]$W = $img.Width
  [int]$H = $img.Height
  for ([int]$x = 0; $x -lt $W; $x++) {
    for ([int]$y = 0; $y -lt $H; $y++) {
      $c = $bmp.GetPixel($x, $y)
      if ($c.A -gt 0) {
        [double]$t = $y / [double]$H
        [int]$r = [int]($tR + (($bR - $tR) * $t))
        [int]$g = [int]($tG + (($bG - $tG) * $t))
        [int]$b = [int]($tB + (($bB - $tB) * $t))
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $r, $g, $b))
      }
    }
  }
  $img.Dispose()
  $tmp = "$env:TEMP\icon-grad.png"
  $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Move-Item $tmp $p -Force
  Write-Output "$f -> gradient applied (${W}x${H})"
}
Write-Output "ALL DONE"
