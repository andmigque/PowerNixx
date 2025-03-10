# Enable strict mode for better error handling
Set-StrictMode -Version 3.0
# Disable PowerShell telemetry
Set-Variable -Name 'POWERSHELL_TELEMETRY_OPTOUT' -Value 'true'	
Set-Variable -Name 'PowerNixx' -Value "$env:HOME/Develop/PowerNixx"
Set-Variable -Name 'ShowFastFetch' -Value 'false'
Import-Module PSReadLine
Import-Module PSScriptAnalyzer
Import-Module Pester

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Check if running on Linux
if ($IsLinux) {
    # Initialize PATH environment variable
    $env:PATH = ""
    $env:PATH = "/opt/microsoft/powershell/7-lts"
    
    # Add Homebrew paths if brew is installed
    if(Test-Path "/home/linuxbrew/.linuxbrew/bin/brew") {
        $env:PATH = "$($env:PATH):/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin"
    }

    # Add common binary paths
    $env:PATH = "$($env:PATH):/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
    
    # Run fastfetch if available
    if ((Test-Path "/usr/bin/fastfetch") -and ($ShowFastFetch -eq 'true')) {
        fastfetch
    }
}

if(Test-Path "$($env:HOME)/.local/bin/oh-my-posh"){
    $env:PATH = "$($env:PATH):/$($env:HOME)/.local/bin"
    oh-my-posh init pwsh --config "$($env:HOME)/.poshthemes/1_shell.omp.json" | Invoke-Expression
}

# Import PowerNixx Functions
Get-ChildItem -Path "$env:HOME/Develop/PowerNixx/App" -File -Recurse | 
    Where-Object { $_.Extension -eq ".ps1" -and -not ($_.Name -like "*.Tests.ps1") } | 
    ForEach-Object { . $_.FullName }
