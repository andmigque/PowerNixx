function Get-RamUsage {
    # Retrieve all lines from /proc/meminfo
    Get-Content -Path "/proc/meminfo"| ForEach-Object {
        # Split each line into its key and value parts
        $memInfoParts = $_ -split ':'
        
        # Extract and trim memory-related information
        $name = $memInfoParts[0].Trim()
        $valueAndUnit = $memInfoParts[1].Trim() -split '\s+'

        # Convert memory values depenl*ding on the unit
        switch ($valueAndUnit[-1]) {
            'kB' {
                $valueInBytes = [long]$valueAndUnit[0] * 1024
                $humanReadableValue = [math]::Round($valueInBytes / 1GB)
                Write-Host "$($name): $($humanReadableValue) GB"
            }
            'GiB' { # Directly in Gigabytes, though typically not used for meminfo entries
                Write-Host "$($name): $($valueAndUnit[0]) GB"
            }
            default {
                # Any other units like MiB can be handled here if needed
                Write-Host "$($_.Trim()) - Can't conver base"
            }
        }
    }
}