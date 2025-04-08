using namespace System.Formats.Tar
using namespace System.IO
using namespace System.IO.Compression
function ConvertTo-Zip {
    param([string]$SrcDir, [string]$DestDir)



    try {
        # Ensure the source directory exists
        if (!(Test-Path -Path $SrcDir -PathType Container)) {
            throw "Source directory '$SrcDir' does not exist."
        }

        # Ensure the destination directory exists
        if (!(Test-Path -Path $DestDir -PathType Container)) {
            New-Item -Path $DestDir -ItemType Directory | Out-Null
        }

        # Get all files in the source directory
        $files = Get-ChildItem -Path $SrcDir -File

        # Create a zip archive for each file
        foreach ($file in $files) {
            if ($file.Length -lt 100) {
                # Copy the original file instead of compressing
                $destPath = Join-Path -Path $DestDir -ChildPath $file.Name
                Copy-Item -Path $file.FullName -Destination $destPath

                Write-Host "Copied file '$destPath' instead of compressing."
            }
            else {
                $zipPath = Join-Path -Path $DestDir -ChildPath ($file.Name + '.zip')

                # Compress the file to a zip archive
                Compress-Archive -Path $file.FullName -DestinationPath $zipPath -CompressionLevel Optimal

                Write-Host "Successfully created zip archive '$zipPath'."
            }
        }
    }
    catch {
        Write-Error $_
    }
}

function ConvertTo-Gzip {
    param([string]$SrcDir, [string]$DestDir)

    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    $files = Get-ChildItem -Path $source 

    foreach ($file in $files) {
        $filePath = $file.FullName
        $baseName = "$($file.BaseName)$($file.Extension)"
        $gzipFilePath = "$($destination)$($baseName).gz"
        # Create a FileStream for reading the original file
        $fileStream = [System.IO.File]::OpenRead($filePath)

        # Create a FileStream for writing the compressed file
        $gzipStream = [System.IO.File]::Create($gzipFilePath)

        # Create a GZipStream for compression, writing to the gzip file
        $gzipWriter = [System.IO.Compression.GZipStream]::new($gzipStream, [System.IO.Compression.CompressionLevel]::SmallestSize, $false)

        # Ensure the stream is closed properly
        try {
            # Copy data from the file stream to the gzip stream
            $fileStream.CopyTo($gzipWriter)
        }
        finally {
            # Close both streams to release resources
            $gzipWriter.Close()
            $fileStream.Close()
            
        }
    }

}

function ConvertTo-GzipParallel {
    param([string]$SrcDir, [string]$DestDir)

    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    Get-ChildItem -Path $source -Recurse -File | ForEach-Object -Parallel {
        $filePath = $_.FullName
        $baseName = "$($_.BaseName)$($_.Extension)"
        $gzipFilePath = "$($Using:destination)$($baseName).gz"
        # Create a FileStream for reading the original file
        $fileStream = [System.IO.File]::OpenRead($filePath)

        # Create a FileStream for writing the compressed file
        $gzipStream = [System.IO.File]::Create($gzipFilePath)

        # Create a GZipStream for compression, writing to the gzip file
        $gzipWriter = [System.IO.Compression.GZipStream]::new($gzipStream, [System.IO.Compression.CompressionLevel]::SmallestSize, $false)

        # Ensure the stream is closed properly
        try {
            # Copy data from the file stream to the gzip stream
            $fileStream.CopyTo($gzipWriter)
        }
        finally {
            # Close both streams to release resources
            $gzipWriter.Close()
            $fileStream.Close()
            
        }
    }

}