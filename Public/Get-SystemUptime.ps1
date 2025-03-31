function Get-SystemUptime {
    [CmdletBinding()]
    param(
        # No parameters required as this function queries the system directly
    )

    <#
    .SYNOPSIS
    Gets the system uptime in a human-readable format.

    .DESCRIPTION
    This function retrieves the system uptime by reading from '/proc/uptime' on Linux systems.
    It returns a formatted string representing the number of days, hours, minutes, and seconds since the last boot.

    .EXAMPLE
    PS> Get-SystemUptime

    .NOTES
    Author: AI Assistant
    Date: October 2023
    #>

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