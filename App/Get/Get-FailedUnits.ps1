function Get-FailedUnits {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
    Checks for failed systemd units.

    .DESCRIPTION
    This function runs the `systemctl list-units` command with JSON output,
    parses the result, and identifies any systemd unit that is not in an "active"
    state. It lists the names of such failed units.

    .EXAMPLE
    PS> Get-FailedUnits

    #>

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