Set-StrictMode -Version 3.0

function Get-InstalledPackages {
    [CmdletBinding()]
    param()
    try {
        $aptOutput = & apt list --installed 2>&1
        $dpkgOutput = & dpkg-query -l 2>&1

        return @{
            "apt" = $aptOutput
            "dpkg" = $dpkgOutput
        }
    }
    catch {
        Write-Error $_
    }
}


function Get-AllPackages {
    [CmdletBinding()]
    param()

    try {
        $dpkgQuery = & dpkg-query -f '${binary:Package}\n' -W 2>&1
        return $dpkgQuery
    }
    catch {
        Write-Error $_
    }
}

function Get-PackageCount {
    [CmdletBinding()]
    param()

    try {
        $packageCount = & dpkg-query -f '${binary:Package}\n' -W 2>&1
        return $packageCount
    }
    catch {
        Write-Error $_
        
    }
}

function Get-ModuleMembers {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$true)]
        [string]$Name
    )

    try {
        return (Get-Module -Name $Name -ListAvailable -All | Get-Member -MemberType All -Force)
    } catch {
        Write-Error $_
    }
}

function Get-PsModulePaths {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$false)]
        [string]$Name
    )
    
    try {
        
        $psModulePaths = ($Env:PSModulePath) -split(":") | 
        ForEach-Object -Parallel { 
            $Count = (Test-Path -Path $_) ? (Get-ChildItem -Path $_ -Directory).Count : 0
            
            [PSCustomObject]@{
                "ModulePath" = "$_"
                "Count" = "$Count"
            }
        }
        return $psModulePaths
    } catch {
        Write-Error $_
    }
}

function Repair-AllAptitudePackages {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$false)]
        [string]$Name
    )
    
    try {
        $reinstalls = & sudo aptitude -y reinstall '~i' 2>&1
        return $reinstalls
    } catch {
        Write-Error $_
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
        Write-Error $_
    }
}

function Install-Homebrew {
    [CmdletBinding()]
    param (
        [switch] $Confirm
    )

    if ($Confirm) {
        $confirmation = Read-Host "Are you sure you want to install Homebrew? (y/n)"
        if ($confirmation -ne 'y') {
            Write-Host "Installation canceled."
            return
        }
    }

    try {
        Invoke-Expression "zsh -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"
        Write-Host "Homebrew installed successfully."
    } catch {
        Write-Error "An error occurred while installing Homebrew: $_"
    }
}

function Get-PackageDetails {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName
    )

    try {
        $packageInfo = & dpkg-query -W -f='${Status} ${binary:Package} ${Version} ${binary:Architecture} ${Maintainer} ${Description}\n' $PackageName
        return $packageInfo
    } catch {
        Write-Error $_
    }
}

function Update-Packages {
    [CmdletBinding()]
    param(
        [switch]$UpgradeAll
    )

    try {
        if ($UpgradeAll) {
            & sudo apt-get upgrade -y
        } else {
            & sudo apt-get update -y
        }
    } catch {
        Write-Error $_
    }
}

function Find-Package {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName
    )

    try {
        $packageInfo = & dpkg-query -W -f='${Status} ${binary:Package} ${Version} ${binary:Architecture} ${Maintainer} ${Description}\n' *$PackageName*
        return $packageInfo
    } catch {
        Write-Error $_
    }
}

function Remove-Package {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName
    )

    try {
        & sudo dpkg --purge --force-depends $PackageName
    } catch {
        Write-Error $_
    }
}

function Get-RepositoryDetails {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$RepositoryName = 'PSGallery'
    )

    try {
        $repositoryInfo = Get-PSRepository -Name $RepositoryName
        return $repositoryInfo
    } catch {
        Write-Error $_
    }
}