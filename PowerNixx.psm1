$Public = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Recurse)

$Public | ForEach-Object {
    try {
        . $_.FullName
    }
    catch {
        Write-Error "Failed to import public function $($_.FullName): $($_.Exception.Message)"
    }
}

$manifestPath = Join-Path $PSScriptRoot 'PowerNixx.psd1'
if (-Not (Test-Path $manifestPath)) {
    throw "Manifest file not found at $manifestPath"
}

$manifest = Import-PowerShellDataFile -Path $manifestPath
if (-Not $manifest.FunctionsToExport) {
    throw 'FunctionsToExport is not defined in the manifest file.'
}

Export-ModuleMember -Function $manifest.FunctionsToExport
. (Join-Path -Path $PSScriptRoot -ChildPath 'Public/PsNxEnums.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Public/PsNxResult.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Public/ByteMapper.ps1')

$PSStyle.OutputRendering = 'Ansi'