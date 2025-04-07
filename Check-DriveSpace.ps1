
param([string]$driveName = "", [int64]$minLevel = 10 * 1000 * 1000) # GB

function Bytes2String { param([int64]$bytes)
        if ($bytes -lt 1000) { return "$bytes bytes" }
        $bytes /= 1000
        if ($bytes -lt 1000) { return "$($bytes)KB" }
        $bytes /= 1000
        if ($bytes -lt 1000) { return "$($bytes)MB" }
        $bytes /= 1000
        if ($bytes -lt 1000) { return "$($bytes)GB" }
        $bytes /= 1000
        if ($bytes -lt 1000) { return "$($bytes)TB" }
        $bytes /= 1000
        return "$($bytes)PB"
}

function Check-DriveSpace {
        try {
                if ($driveName -eq "" ) { $driveName = Read-Host "Enter the drive name to check" }

                $details = (Get-PSDrive $driveName)
                if (-not $IsLinux) { $driveName = $driveName + ":" }
                [int64]$free = $details.Free
                [int64]$used = $details.Used
                [int64]$total = ($used + $free)

                if ($total -eq 0) {
                        Write-Host "✅ Drive $driveName is empty"
                } elseif ($free -eq 0) {
                        Write-Host "⚠️ Drive $driveName with $(Bytes2String $total) is full"
                } elseif ($free -lt $minLevel) {
                        Write-Host "⚠️ Drive $driveName with $(Bytes2String $total) is nearly full, $(Bytes2String $free) free"
                } else {
                        [int64]$percent = ($used * 100) / $total
                        Write-Host "✅ Drive $driveName uses $percent% of $(Bytes2String $total) - $(Bytes2String $free) free"
                }
        } catch {
                "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
        }   
}

