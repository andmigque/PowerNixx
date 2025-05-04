using namespace System.Formats.Tar

function ConvertFrom-DirToTar {
    param([string]$SrcDir, $TarFilePath)

    # Create the tar archive
    $source = (Resolve-Path -Path $SrcDir).Path
    #$filePath = Resolve-Path -Path $TarFilePath

    try {
        $ErrorActionPreference = 'Stop'
        [TarFile]::CreateFromDirectory($source, $TarFilePath, $true)
        Write-Host "Tar file created successfully at: $filePath"
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        Write-Host $_.ScriptStackTrace
    }
}

function ConvertFrom-DirToTarFiles {
    param([string]$SrcDir, [string]$DestDir)

    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    try {
        Write-Host $source
        Write-Host $destination

        $files = Get-ChildItem -Path $source 

        foreach ($file in $files) {

            try {
                $filePath = $file.FullName
                $baseName = [IO.Path]::GetFileNameWithoutExtension($filePath)
                $tarFilePath = "$($destination)$($baseName).tar"
    
                Write-Host $filePath
                Write-Host $baseName
                Write-Host $tarFilePath
    
                $fileStream = [System.IO.File]::OpenRead($filePath)
                $tarStream = [System.IO.File]::Create($tarFilePath)
                $tarWriter = [TarWriter]::new($tarStream, [TarEntryFormat]::Gnu, $true)
                $tarEntry = [GnuTarEntry]::new('RegularFile', $baseName)
                
                $tarEntry.DataStream = $fileStream
                $tarWriter.WriteEntry($tarEntry)
            } catch {
                Write-Information $_
                Write-Information $_.Exception.StackTrace
                Write-Information $_.ScriptStackTrace
            } finally {
                $tarWriter.Dispose()
                $fileStream.Dispose()
                $tarStream.Dispose()
            }

        }
    }
    catch {
        Write-Error $_
        Write-Error $_.Exception.StackTrace
        Write-Error $_.ScriptStackTrace
    }
}
