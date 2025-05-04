# Import script-level variables first
$Public = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Recurse)

# Dot source public files
$Public | ForEach-Object {
    try {
        . $_.FullName
    }
    catch {
        Write-Error "Failed to import public function $($_.FullName): $($_.Exception.Message)"
    }
}

# Validate manifest file
$manifestPath = Join-Path $PSScriptRoot 'PowerNixx.psd1'
if (-Not (Test-Path $manifestPath)) {
    throw "Manifest file not found at $manifestPath"
}

# Import manifest and validate FunctionsToExport
$manifest = Import-PowerShellDataFile -Path $manifestPath
if (-Not $manifest.FunctionsToExport) {
    throw "FunctionsToExport is not defined in the manifest file."
}

# Export all functions listed in the psd1's FunctionsToExport
Export-ModuleMember -Function $manifest.FunctionsToExport

# Set output rendering for PowerShell 7+

$PSStyle.OutputRendering = 'Ansi'