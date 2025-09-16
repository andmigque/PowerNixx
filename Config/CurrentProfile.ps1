# Enable strict mode for better error handling
Set-StrictMode -Version 3.0    
Set-Variable -Name PSModuleAutoLoadingPreference -Value 'All'

# Disable PowerShell telemetry
Set-Variable -Name 'POWERSHELL_TELEMETRY_OPTOUT' -Value 'true'	
Set-Variable -Name 'ShowFastFetch' -Value 'false'

if($IsLinux) {
    Set-Variable -Name 'PowerNixx' -Value "$env:HOME/Develop/PowerNixx"
}elseif ($IsWindows) {
    Set-Variable -Name 'PowerNixx' -Value "$env:USERPROFILE\source\PowerNixx"
}
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
    $env:PATH = '/opt/microsoft/powershell/7'
    
    # Add common binary paths
    $env:PATH = "$($env:PATH):/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
    # Add Homebrew paths if brew is installed
    if (Test-Path '/home/linuxbrew/.linuxbrew/bin/brew') {
        $env:PATH = "$($env:PATH):/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin"
    }

    # If Llama Cpp
    if (Test-Path "$($env:HOME)/Develop/llama.cpp/build/bin") {
        $env:PATH = "$($env:PATH):$env:HOME/Develop/llama.cpp/build/bin"
    }

    if ((Test-Path "$($env:HOME)/.lmstudio/bin")) {
        $env:PATH = "$($env:PATH):$($env:HOME)/.lmstudio/bin"
    }

    # Run fastfetch if available
    if ((Test-Path '/usr/bin/fastfetch') -and ($ShowFastFetch -eq 'true')) {
        fastfetch
    }
}

if (Test-Path "$($env:HOME)/.local/bin/oh-my-posh") {
    $env:PATH = "$($env:PATH):$($env:HOME)/.local/bin"
    #oh-my-posh init pwsh --config "$($env:HOME)/.poshthemes/clean-detailed.omp.json" | Invoke-Expression
    oh-my-posh init pwsh --config "$($env:HOME)/.poshthemes/1_shell.omp.json" | Invoke-Expression
    #oh-my-posh init pwsh --config "$($env:HOME)/.poshthemes/free-ukraine.omp.json" | Invoke-Expression
}

# Set Style to Ansi
$PSStyle.OutputRendering = 'Ansi'
