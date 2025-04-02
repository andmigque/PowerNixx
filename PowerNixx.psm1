# Import script-level variables first
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue)
$Public = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Recurse -ErrorAction SilentlyContinue)

Write-Verbose 'PowerNixx Module Loading...'
Write-Verbose "Found $($Private.Count) private files"
Write-Verbose "Found $($Public.Count) public files"

# Dot source private files first
$Private | ForEach-Object {
    try {
        . $_.FullName
        Write-Verbose "Imported private file: $($_.Name)"
    }
    catch {
        Write-Error "Failed to import private function $($_.FullName): $_"
    }
}

# Dot source public files
$Public | ForEach-Object {
    try {
        . $_.FullName
        Write-Verbose "Imported public file: $($_.Name)"
    }
    catch {
        Write-Error "Failed to import public function $($_.FullName): $_"
    }
}

# Export all functions listed in the psd1's FunctionsToExport
$manifestPath = Join-Path $PSScriptRoot 'PowerNixx.psd1'
$manifest = Import-PowerShellDataFile -Path $manifestPath
Write-Verbose "Exporting $($manifest.FunctionsToExport.Count) functions"
Export-ModuleMember -Function $manifest.FunctionsToExport
Write-Verbose 'PowerNixx Module Loaded Successfully'
$PSStyle.OutputRendering = 'Ansi'