Add-Type -AssemblyName System.Drawing
$src = "C:\Users\PC\Desktop\New folder (3)\New folder\Timber Import.jpg"
$outDir = "C:\Users\PC\Documents\Default Project\bensoltan-ecommerce\icon-preview-assets"

$img = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap($img)
[int]$W = $img.Width
[int]$H = $img.Height
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$black = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)

# ===== Step 1: detect the knockout extent FIRST (on the pristine original) =====
# True knockout interior: light pixel with dark mass above AND below
[int]$kMinX = $W; [int]$kMaxX = 0; [int]$kMinY = $H; [int]$kMaxY = 0; [int]$kCount = 0
for ([int]$x = 155; $x -le 480; $x++) {
  for ([int]$y = 406; $y -le 428; $y++) {
    $c = $bmp.GetPixel($x, $y)
    [int]$lum = ($c.R + $c.G + $c.B) / 3
    if ($lum -gt 185) {
      $cUp = $bmp.GetPixel($x, ($y - 6)); $cDn = $bmp.GetPixel($x, ($y + 6))
      [int]$lUp = ($cUp.R + $cUp.G + $cUp.B) / 3
      [int]$lDn = ($cDn.R + $cDn.G + $cDn.B) / 3
      if (($lUp -lt 110) -and ($lDn -lt 110)) {
        $kCount++
        if ($x -lt $kMinX) { $kMinX = $x }
        if ($x -gt $kMaxX) { $kMaxX = $x }
        if ($y -lt $kMinY) { $kMinY = $y }
        if ($y -gt $kMaxY) { $kMaxY = $y }
      }
    }
  }
}
Write-Output "Knockout detected: x $kMinX-$kMaxX, y $kMinY-$kMaxY ($kCount px)"

# ===== Step 2: erase old text (y 369-400 — includes letter tops at 372) =====
[int]$ex = 196; [int]$ey = 369; [int]$ew = 234; [int]$eh = 31
$g.FillRectangle($white, $ex, $ey, $ew, $eh)
Write-Output "Erased old text: (196,369) 234x31"

# ===== Step 3: B.S.C fitted in the taller zone =====
[double]$size = 36; $font = $null; $sz = $null
while ($size -ge 8) {
  $font = New-Object System.Drawing.Font("Arial Black", [float]$size, [System.Drawing.FontStyle]::Regular)
  $sz = $g.MeasureString("B.S.C", $font)
  if (($sz.Width -le 200) -and (($sz.Height * 0.78) -le 29)) { break }
  $size = $size - 1
}
$fmt = New-Object System.Drawing.StringFormat
$fmt.Alignment = [System.Drawing.StringAlignment]::Center
$fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
$rect = New-Object System.Drawing.RectangleF([float]$ex, [float]($ey + 1), [float]$ew, [float]($eh - 2))
$g.DrawString("B.S.C", $font, $black, $rect, $fmt)
Write-Output "B.S.C (font $size, $([math]::Round($sz.Width))x$([math]::Round($sz.Height)))"

# ===== Step 4: fill knockout zone black (data-driven bbox + padding) =====
[int]$fx0 = [Math]::Max(150, ($kMinX - 10))
[int]$fx1 = [Math]::Min(490, ($kMaxX + 10))
[int]$fy0 = [Math]::Max(398, ($kMinY - 8))
[int]$fy1 = [Math]::Min(440, ($kMaxY + 8))
$g.FillRectangle($black, $fx0, $fy0, ($fx1 - $fx0 + 1), ($fy1 - $fy0 + 1))
Write-Output "Filled knockout: ($fx0,$fy0)-($fx1,$fy1)"

$bmp.Save("$outDir\timber-bsc-black.png", [System.Drawing.Imaging.ImageFormat]::Png)

# ===== Blue transparent =====
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
$nb.Save("$outDir\timber-bsc-blue.png", [System.Drawing.Imaging.ImageFormat]::Png)

# ===== Verification =====
$chars = " .:-=+*#%@"
Write-Output ""
Write-Output "=== FINAL VERIFY (x 150-490, y 365-450) 85x18 ==="
for ($gy = 0; $gy -lt 18; $gy++) {
  $line = ""
  for ($gx = 0; $gx -lt 85; $gx++) {
    $x0 = 150 + [int](($gx * 340) / 85)
    $y0 = 365 + [int](($gy * 85) / 18)
    $x1 = 150 + [int]((($gx + 1) * 340) / 85)
    $y1 = 365 + [int]((($gy + 1) * 85) / 18)
    $sum = 0; $n = 0
    for ($y = $y0; $y -lt $y1; $y++) { for ($x = $x0; $x -lt $x1; $x++) { $c = $bmp.GetPixel($x, $y); $sum += ($c.R + $c.G + $c.B); $n++ } }
    $lum = if ($n -gt 0) { $sum / (3 * $n) } else { 255 }
    $idx = [int]((9 * (255 - $lum)) / 255); if ($idx -gt 9) { $idx = 9 }
    $line += $chars[$idx]
  }
  Write-Output $line
}

$g.Dispose(); $nb.Dispose(); $img.Dispose(); $bmp.Dispose()
Write-Output "DONE"
