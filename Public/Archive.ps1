using namespace System.Formats.Tar

function ConvertFrom-DirToTar {
    param([string]$SrcDir, $TarFilePath)

    # Create the tar archive
    $source = (Resolve-Path -Path $SrcDir).Path
    #$filePath = Resolve-Path -Path $TarFilePath

    try {
        $ErrorActionPreference = 'Stop'
        [TarFile]::CreateFromDirectory($source, $TarFilePath, $true)
        Write-Host "Tar file created successfully at: $TarFilePath"
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        Write-Host $_.ScriptStackTrace
    }
}