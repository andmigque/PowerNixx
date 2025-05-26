using namespace System.Formats.Tar
Set-StrictMode -Version 3.0

function ConvertFrom-DirToTar {
    param([string]$SourceDirectory, $TarFilePath)


    if (-not (Test-Path -Path $SourceDirectory)) {
        throw "Source directory does not exist: $SourceDirectory"
    }
    try {
        $ErrorActionPreference = 'Stop'
        [TarFile]::CreateFromDirectory($SourceDirectory, $TarFilePath, $true)
        Write-Host "Tar file created successfully at: $TarFilePath"
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        Write-Host $_.ScriptStackTrace
    }
}