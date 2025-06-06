Set-StrictMode -Version 3.0

function Get-Bios {
    try {
        if ($IsLinux) {
            $model = (sudo dmidecode -s system-product-name)
            if ("$model" -eq "") { exit 0 } # no information
            $version = (sudo dmidecode -s bios-version)
            $releaseDate = (sudo dmidecode -s bios-release-date)
            $manufacturer = (sudo dmidecode -s system-manufacturer)
        } else {
            $details = Get-CimInstance -ClassName Win32_BIOS
            $model = $details.Name.Trim()
            $version = $details.Version.Trim()
            $serial = $details.SerialNumber.Trim()
            $manufacturer = $details.Manufacturer.Trim()
        }
        if ($model -eq "To be filled by O.E.M.") { $model = "N/A" }
        if ($version -eq "To be filled by O.E.M.") { $version = "N/A" }
        if ("$releaseDate" -ne "") { $releaseDate = " of $releaseDate" }
    
        Write-Host "BIOS model $model, version $($version)$($releaseDate), $manufacturer"
    } catch {
        "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}
