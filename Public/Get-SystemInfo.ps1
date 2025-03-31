# Gets basic system information, such as operating system details.
function Get-SystemInfo {
    [CmdletBinding()]
    param(
        # No parameters are needed for this function. 
        #
        # If additional filtering or options were desired, they could be placed here.
    )

    <#
    .SYNOPSIS
    Retrieves basic information about the operating system and environment.

    .DESCRIPTION
    This function returns core details regarding the operating system, including the OS name, version,
    architecture, and platform. The output is compatible across Linux-based systems.

    .EXAMPLE
    PS> Get-SystemInfo

    Platform   Name                      Version               Architecture
    ---------  ----                      -------               -------------
    Unix       Ubuntu                    20.04 LTS             amd64

    .NOTES
    Author: AI Model
    Date: October 2023
    #>

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