<#
.NOTES
Author: Andres Quesada
Date: February 20, 2025
#>

function Get-InstalledPackages {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
    Displays installed packages using apt and dpkg.

    .DESCRIPTION
    This function retrieves and displays installed packages using both apt list
    and dpkg-query commands, piping the results through less for easy viewing.

    .EXAMPLE
    PS> Get-InstalledPackages
    # Shows both apt and dpkg package listings through less

    .OUTPUTS
    System.Void
    #>

    try {
        (apt list --installed)
        (dpkg-query -l)
    }
    catch {
        Write-Error "Failed to get installed packages: $_"
    }
}

function Get-AllPackages {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
    Lists all installed packages.

    .DESCRIPTION
    Returns a list of all installed packages using dpkg-query with custom formatting.

    .EXAMPLE
    PS> Get-AllPackages
    # Returns list of package names

    .OUTPUTS
    System.String[]
    #>

    try {
        (dpkg-query -f '${binary:Package}\n' -W)
    }
    catch {
        Write-Error "Failed to list all packages: $_"
    }
}

function Get-PackageCount {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
    Counts total installed packages.

    .DESCRIPTION
    Returns the total count of installed packages on the system using dpkg-query.

    .EXAMPLE
    PS> Get-PackageCount
    1500

    .OUTPUTS
    System.Int32
    #>

    try {
        return (dpkg-query -f '${binary:Package}\n' -W).Count
    }
    catch {
        Write-Error "Failed to count packages: $_"
        return 0
    }
}

function Get-ModuleMembers {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$true)]
        [string]$Name
    )

    try {
        Get-Module -Name $Name -ListAvailable -All | Get-Member -MemberType All -Force
    } catch {
        Write-Error $Error
    }
}

function Get-PsModulePaths {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$false)]
        [string]$Name
    )
    
    try {
        
        ($Env:PSModulePath) -split(":") | 
        ForEach-Object -Parallel { 
            $Count = (Test-Path -Path $_) ? (Get-ChildItem -Path $_ -Directory).Count : 0
            
            [PSCustomObject]@{
                "ModulePath" = "$_"
                "Count" = "$Count"
            }
        } | Format-Table
    } catch {
        Write-Error $Error
    }
}

function Repair-AllAptitudePackages {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$false)]
        [string]$Name
    )
    
    try {
        (sudo aptitude -y reinstall '~i')
    } catch {
        Write-Error $Error
    }
}

function Protect-Repository {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$false)]
        [string]$Repository="PSGallery"
    )
    
    try {
        Set-PSRepository -InstallationPolicy Trusted -Name $Repository
    } catch {
        Write-Error $Error
    }
}

function Invoke-Homebrew {
    param ()
    
    Invoke-Expression "zsh -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"
    
}