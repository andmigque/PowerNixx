function Check-Bios {
	try {
		if ($IsLinux) {
			$model = (sudo dmidecode -s system-product-name)
			if ("$model" -eq "") { exit 0 } # no information
			Write-Progress "Querying BIOS details..."
			$version = (sudo dmidecode -s bios-version)
			#$releaseDate = (sudo dmidecode -s bios-release-date)
			$manufacturer = (sudo dmidecode -s system-manufacturer)
			Write-Progress -completed "Done."
		} else {
			$details = Get-CimInstance -ClassName Win32_BIOS
			$model = $details.Name.Trim()
			$version = $details.Version.Trim()
			$serial = $details.SerialNumber.Trim()
			$manufacturer = $details.Manufacturer.Trim()
		}
		if ($model -eq "To be filled by O.E.M.") { $model = "N/A" }
		if ($version -eq "To be filled by O.E.M.") { $version = "N/A" }
		#if ("$releaseDate" -ne "") { $releaseDate = " of $releaseDate" }
		if ("$serial" -eq "") { $serial = "N/A" }
		if ($serial -eq "To be filled by O.E.M.") { $serial = "N/A" }
		Write-Host "✅ BIOS model $model, version $($version)$, S/N $serial by $manufacturer"
	} catch {
		"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	}
	
}
