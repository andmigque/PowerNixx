Set-StrictMode -Version 3.0

function Get-SystemInfo {
    [CmdletBinding()]
    param()

    try {
        
        $memoryJob = {
            Import-Module ./PowerNixx.psd1
            $memoryPercent = (Get-Memory).UsedPercent
            Write-Output @{
                MemoryPercent = $memoryPercent
            } | Select-Object -Property MemoryPercent
        }

        $cpuJob = {
            Import-Module ./PowerNixx.psd1
            $cpuPercent = (Get-CpuFromProc).TotalUsage
            Write-Output @{
                CpuPercent = $cpuPercent
            } | Select-Object -Property CpuPercent
        }

        $diskJob = {
            Import-Module ./PowerNixx.psd1
            return Get-DiskIO 
        }

        $netJob = {
            Import-Module ./PowerNixx.psd1
            return Get-NetworkStats
        }

        $scriptBlocks = @($memoryJob, $cpuJob, $diskJob, $netJob) | ForEach-Object {
            Start-ThreadJob $_
        }
        
        $jobs = $scriptBlocks | Receive-Job -Wait -AutoRemoveJob

        return $jobs
    }
    catch {
        Write-Error "Failed to retrieve system information. Error: $_"
    }
}

function Get-SystemUptime {
    [CmdletBinding()]
    param()
    try {
        if (-not $IsLinux) { 
            throw 'This function is only supported on Linux-based systems.'
        }

        $uptimeContent = Get-Content -Path '/proc/uptime'
        $uptimeSeconds = [double]$uptimeContent.Split(' ')[0]

        $days = [math]::Floor($uptimeSeconds / (24 * 3600))
        $hours = [math]::Floor(($uptimeSeconds % (24 * 3600)) / 3600)
        $minutes = [math]::Floor(($uptimeSeconds % 3600) / 60)
        $seconds = [math]::Floor($uptimeSeconds % 60)

        # Format the output
        return "Uptime: ${days}d, ${hours}h, ${minutes}m, ${seconds}s"
    }
    catch {
        Write-Error "Failed to retrieve system uptime. Error: $_"
    }
}

function Get-PowershellHistory {
    param()
    (Get-PSReadLineOption).HistorySavePath
    Get-Content -Path (Get-PSReadLineOption).HistorySavePath
}

function Get-FailedUnits {
    [CmdletBinding()]
    param()

    try {
        $FailedUnits = Invoke-Expression 'systemctl list-units --output=json' | `
                ConvertFrom-Json | Where-Object -FilterScript { `
                    $_.active -ne 'active' `
            }

        return $FailedUnits
    }
    catch {
        Write-Error $_
    }
}

function Set-Suspend {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Enable', 'Disable')]
        [string]$Mode
    )

    try {
        switch ($Mode) {
            'Enable' {
                sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
                Write-Host 'Suspend is now enabled.'
            }
            'Disable' {
                sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
                Write-Host 'Suspend is now disabled.'
            }
        }
    }
    catch {
        Write-Error "Failed to set suspend mode to $Mode. Error: $_"
    }
}

