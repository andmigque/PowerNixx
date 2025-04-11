# Gets basic system information, such as operating system details.
function Get-SystemInfo {
    [CmdletBinding()]
    param()

    try {
        # Collect information in a hashtable
        $systemInfo = @{
            Version    = [System.Environment]::OSVersion.VersionString
            Architecture = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        }

        # Output the information as a custom object
        New-Object PSObject -Property $systemInfo | Format-Table -AutoSize
    }
    catch {
        Write-Error "Failed to retrieve system information. Error: $_"
    }
}

function Get-SystemUptime {
    [CmdletBinding()]
    param()
    try {
        # Check if running on a Linux-based system
        if (-not $IsLinux) { 
            throw "This function is only supported on Linux-based systems."
        }

        # Read the uptime from /proc/uptime
        $uptimeContent = Get-Content -Path '/proc/uptime'
        $uptimeSeconds = [double]$uptimeContent.Split(' ')[0]

        # Convert seconds to days, hours, minutes, and seconds
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
        # Run systemctl to get all unit statuses in JSON format
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
        [Parameter(Mandatory=$true)]
        [ValidateSet('Enable', 'Disable')]
        [string]$Mode
    )

    try {
        switch ($Mode) {
            'Enable' {
                sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
                Write-Host "Suspend is now enabled."
            }
            'Disable' {
                sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
                Write-Host "Suspend is now disabled."
            }
        }
    }
    catch {
        Write-Error "Failed to set suspend mode to $Mode. Error: $_"
    }
}

