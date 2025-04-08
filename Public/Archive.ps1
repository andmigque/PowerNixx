
function ConvertTo-Tar {
    param([string]$SrcDir, [string]$DestDir)

    try {
        # Ensure the source directory exists
        if (!(Test-Path -Path $SrcDir -PathType Container)) {
            throw "Source directory '$SrcDir' does not exist."
        }

        # if (!(Test-Path -Path $DestDir -PathType Container)) {
        #     New-Item -Path $DestDir -ItemType File | Out-Null
        # }

        $SrcDir = (Resolve-Path -Path $SrcDir).Path
        $DestDir = (Resolve-Path -Path $DestDir).Path
        # Create the tar archive
        [TarFile]::CreateFromDirectory($SrcDir, $DestDir, $false)  # $false means don't include base directory

        Write-Host "Successfully created tar archive '$DestDir'."

    }
    catch {
        Write-Error $_ # Just do this, anything more is overkill for a snippet
    }
}


function ConvertFrom-DirToTar {
    param([string]$SrcDir, $TarFilePath)

    # Create the tar archive
    $source = (Resolve-Path -Path $SrcDir).Path
    $filePath = (Resolve-Path -Path $TarFilePath).Path

    try {
        [System.Formats.Tar.TarFile]::CreateFromDirectory($source, $filePath, $true)
        Write-Host "Tar file created successfully at: $filePath"
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        Write-Host $_.ScriptStackTrace
    }
}

function ConvertFrom-DirToTarFIles {
    param([string]$SrcDir, [string]$DestDir)

    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    try {
        Write-Host $source
        Write-Host $destination

        $files = Get-ChildItem -Path $source 

        foreach ($file in $files) {

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
        }
    }
    catch {
        Write-Error $_
        Write-Error $_.Exception.StackTrace
        Write-Error $_.ScriptStackTrace
    }
}
