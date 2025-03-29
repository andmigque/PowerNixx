function Convert-MemUnits {
    param([string]$valueAndUnit)

    
}

function Get-RamPercentage {
    # Retrieve all lines from /proc/meminfo
    if($IsLinux) {
        $ram = Get-Content -Path "/proc/meminfo"

        $memTotalBytes = 0
        $memActiveBytes = 0

        foreach($line in $ram) {
            if($line.Contains('MemTotal:')) {
                $parts = $line -split '\s+'
                $memTotalBytes = $parts[1]
            } elseif($line.Contains('MemFree:')) {
                $parts = $line -split '\s+'
                $memActiveBytes = $parts[1]
            }
        }

        if($memTotalBytes -ne 0 -and $memActiveBytes -ne 0) {
            Write-Host "MemAvailable: $memActiveBytes, Total: $memTotalBytes"
            return $memTotalBytes - $memActiveBytes
        } else {
            throw 'Error: Memory values not captured from /proc/meminfo'
        }
    }
}