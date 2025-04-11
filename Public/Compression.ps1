
function ConvertTo-GzipParallel {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SrcDir,

        [Parameter(Mandatory = $true)]
        [string]$DestDir
    )

    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    # Check if source and destination directories exist
    if (-not (Test-Path -Path $source)) {
        throw "Source directory '$source' does not exist."
    }

    if (-not (Test-Path -Path $destination)) {
        throw "Destination directory '$destination' does not exist."
    }

    Get-ChildItem -Path $source -Recurse -File | ForEach-Object -Parallel {
        $filePath = $_.FullName
        $baseName = $_.Name
        $gzipFilePath = Join-Path -Path $Using:destination -ChildPath ($baseName + '.gz')

        try {
            # Create a FileStream for reading the original file
            $fileStream = [System.IO.File]::OpenRead($filePath)

            # Create a FileStream for writing the compressed file
            $gzipStream = [System.IO.File]::Create($gzipFilePath)

            # Create a GZipStream for compression, writing to the gzip file
            $gzipWriter = [System.IO.Compression.GZipStream]::new($gzipStream, [System.IO.Compression.CompressionLevel]::SmallestSize, $false)

            # Copy data from the file stream to the gzip stream
            $fileStream.CopyTo($gzipWriter)
        }
        catch {
            Write-Error "Error compressing file '$filePath': $($Error[0].Message)"
        }
        finally {
            # Close both streams to release resources
            if ($null -ne $gzipWriter) {
                $gzipWriter.Close()
            }

            if ($null -ne $fileStream) {
                $fileStream.Close()
            }
        }
    }
}