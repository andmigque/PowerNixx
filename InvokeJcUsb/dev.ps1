[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Reload,
    
    [Parameter()]
    [switch]$Test,
    
    [Parameter()]
    [switch]$CheckDependencies
)

$moduleName = 'InvokeJcUsb'
$modulePath = Join-Path $PSScriptRoot 'src' "$moduleName.psd1"

if ($CheckDependencies) {
    $requiredTools = @('jc', 'lsusb')
    $missing = @()
    foreach ($tool in $requiredTools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            $missing += $tool
        }
    }
    
    if ($missing) {
        Write-Warning "Missing required tools: $($missing -join ', ')"
        Write-Host "Install using: sudo apt install $($missing -join ' ')"
        return
    }
    Write-Host "All dependencies are installed" -ForegroundColor Green
}

if ($Reload) {
    Remove-Module $moduleName -ErrorAction SilentlyContinue
    Import-Module $modulePath -Force
    Write-Host "Module reloaded successfully" -ForegroundColor Green
}

if ($Test) {
    Invoke-Pester ./tests/$moduleName.Tests.ps1 -Output Detailed
}