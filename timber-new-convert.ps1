Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\New folder\Timber Import.jpg"
$outDir = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets"

$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height
Write-Output "New image: ${W}x${H}"

# Recolor: luminance -> alpha, color = site blue (like the other shapes)
[byte]$BR = 30; [byte]$BG = 64; [byte]$BB = 175
$nb = New-Object System.Drawing.Bitmap($W, $H)
for ([int]$x = 0; $x -lt $W; $x++) {
  for ([int]$y = 0; $y -lt $H; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    [int]$a = 255 - $lum
    if ($a -lt 12) { $a = 0 }
    $nb.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $BR, $BG, $BB))
  }
}
$nb.Save("$outDir\timber-new-blue.png", [System.Drawing.Imaging.ImageFormat]::Png)
$kb = [math]::Round((Get-Item "$outDir\timber-new-blue.png").Length/1KB)
Write-Output "Saved timber-new-blue.png (${W}x${H}, $kb KB)"

# Also save a copy of the original for the preview comparison
Copy-Item $src "$outDir\timber-new-original.jpg" -Force
Write-Output "Original copied for preview"

# Verification map of the recolored version (should look identical to the original structure)
$chars = " .:-=+*#%@"
Write-Output ""
Write-Output "=== RECOLORED VERIFY: 50x30 map (alpha-based) ==="
for ($gy = 0; $gy -lt 30; $gy++) {
  $line = ""
  for ($gx = 0; $gx -lt 50; $gx++) {
    $x0 = [int](($gx * $W) / 50)
    $y0 = [int](($gy * $H) / 30)
    $x1 = [int]((($gx + 1) * $W) / 50)
    $y1 = [int]((($gy + 1) * $H) / 30)
    $sum = 0; $n = 0
    for ($y = $y0; $y -lt $y1; $y += 2) { for ($x = $x0; $x -lt $x1; $x += 2) { $c = $nb.GetPixel($x, $y); $sum += $c.A; $n++ } }
    $lum = if ($n -gt 0) { $sum / $n } else { 0 }
    $idx = [int]((9 * $lum) / 255); if ($idx -gt 9) { $idx = 9 }
    $line += $chars[$idx]
  }
  Write-Output $line
}

$img.Dispose(); $bmp.Dispose(); $nb.Dispose()
Write-Output "DONE"
