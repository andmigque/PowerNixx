# Enable strict mode for better error handling
Set-StrictMode -Version 3.0    
Set-Variable -Name PSModuleAutoLoadingPreference -Value 'All'

# Disable PowerShell telemetry
Set-Variable -Name 'POWERSHELL_TELEMETRY_OPTOUT' -Value 'true'	
Set-Variable -Name 'ShowFastFetch' -Value 'false'
Set-Variable -Name 'PowerNixx' -Value "$env:HOME/Apps/PowerNixx"

Import-Module $PowerNixx/PowerNixx.psd1

if (Get-Module -Name PSReadLine -ListAvailable) {
    Import-Module PSReadLine

    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Check if running on Linux
if ($IsLinux) {
    # Initialize PATH environment variable
    $env:PATH = ''
    $env:PATH = '/snap/bin'
    
    # Add common binary paths
    $env:PATH = "$($env:PATH):/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
    # Add Homebrew paths if brew is installed
    if (Test-Path '/home/linuxbrew/.linuxbrew/bin/brew') {
        $env:PATH = "$($env:PATH):/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin"
    }

    if ((Test-Path "$($env:HOME)/.lmstudio/bin")) {
        $env:PATH = "$($env:PATH):$($env:HOME)/.lmstudio/bin"
    }

    # Run fastfetch if available
    if ((Test-Path '/usr/bin/fastfetch') -and ($ShowFastFetch -eq 'true')) {
        fastfetch
    }
}


# Define custom prompt function
function prompt {

    # Get current git branch if in a git repository
    $gitBranch = (Test-Path './.git') ? ((Get-Content '.git/HEAD').replace('ref: refs/heads/', '')) : '👎'
    
    # Get current time in short format
    $shortTime = (Get-Date).ToShortTimeString()

    # Set prompt format with git branch and current time
    "`e[1m`e[94m╭PS`e[0m 🦾( ͡⚈ ʖ ͡⚈)🤳`e[1m`e[35m[$gitBranch]`e[0m`e[4m$($executionContext.SessionState.Path.CurrentLocation)`e[36m 🕒 $shortTime`e[0m`
`e[94m╰┈➤`e[0m$(' ' * ($nestedPromptLevel + 1)) "
}