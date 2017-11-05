# This script will copy images from a folder you specify to a subfolder matching its aspect ratio.

<#
.SYNOPSIS
    This script will move images from one folder to a subfolder
	matching the images aspect ratio.
.DESCRIPTION
    This script will scan a folder for images and use the dimensions
	of the image to determine it's aspect ratio. If the aspect ratio
	matches one of the defined ratios in this script, the image is
	move to a subfolder for that aspect ratio. This was designed to
	sort desktop wallpapers downloaded from the internet.
.NOTES
    File Name  : img-sort-by-aspect-ratio.ps1
    Author     : Nicholas King - neking1@outlook.com
.LINK
    https://github.com/viralarchitect/sysadmin-tools
.EXAMPLE
    .\img-sort-by-aspect-ratio.ps1
.EXAMPLE
	.\img-sort-by-aspect-ratio.ps1 -Source "C:\Downloads" -Destination "C:\Wallpapers"
#>

$imgDir = Read-Host "Where are the images you want to sort?"

#Aspect ratios - keep these arrays in sync!
$strRatios = @("16-10","16-9","4-3","5-4","21-10","21-9")
$AllRatios =   (16/10),(16/9),(4/3),(5/4),(21/10),(21/9)

$filetypes = @("*.jpg","*.png","*.bmp","*.jpeg","*.gif")

Add-Type -AssemblyName System.Drawing

$inputFiles = Get-Childitem $imgDir -include $filetypes -recurse

for ($counter=0; $counter -lt $AllRatios.Length; $counter++){
	Write-Host `n"--------------------------------------------------------------------------------"
	Write-Host   "Scanning images for aspect ratio" ($strRatios[$counter] -replace "-", ":")
	Write-Host   "--------------------------------------------------------------------------------"
	
	foreach ($file in $inputFiles) {
		if (Test-Path $file) {
			$img = New-Object System.Drawing.Bitmap $file.FullName
			$fileRatio = $img.Width / $img.Height
			
			# Horizontal images are not processed
			if ($img.Width -gt $img.Height) {
				$img.Dispose()
				# Calculate the difference of fileRatio and AllRatios
				# and find the index of the closest match
				$differences = $AllRatios | %{  [math]::abs($_ - $fileRatio) }
				$bestmatch = $differences | measure -Minimum
				$index = [array]::IndexOf($differences, $bestmatch.minimum)
				if ($counter -eq $index) {
					if (-Not (Test-Path ($imgDir + "\" + $strRatios[$counter]))) {
						New-Item -ItemType Directory -Force -Path ($imgDir + "\" + $strRatios[$counter]) | Out-Null
					}
					Write-Host `t"Moving File: $file"
					Move-Item $file -Destination ($imgDir + "\" + $strRatios[$counter]) -Force
				}
			} else {
				$img.Dispose()
			}
		}
	}
	Write-Host   "Finished scanning images for aspect ratio" ($strRatios[$counter] -replace "-", ":")
}