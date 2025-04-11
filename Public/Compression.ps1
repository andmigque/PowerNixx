
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

function ConvertTo-BrotliParallel {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SrcDir,

        [Parameter(Mandatory = $true)]
        [string]$DestDir,
        [int]$ProcessorCount = 1
    )
    if(-not ($ProcessorCount -gt 1)) {
        $ProcessorCount = [math]::round(([System.Environment]::ProcessorCount)*.75, 2)
    }
    
    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    # Check if source and destination directories exist
    if (-not (Test-Path -Path $source)) {
        throw "Source directory '$source' does not exist."
    }

    if (-not (Test-Path -Path $destination)) {
        throw "Destination directory '$destination' does not exist."
    }

    $startTime = Get-Date
    Write-Host "From $source to $destination`n" -ForegroundColor Red -BackgroundColor Cyan
    $PSStyle.Reset
    Write-Progress -Activity "Compression --->" -Status "Started @ $startTime"
    Get-ChildItem -Path $source -Recurse -File | ForEach-Object -ThrottleLimit $ProcessorCount -Parallel  {
        
        # Created all the sub directories in the source path in the destination
        $filePath = $_.FullName
        $subDirectory = $filePath.Replace($using:source,'')
        $brotliFilePath = "$($using:destination)$($subDirectory).br"

        $directoryName = [System.IO.Path]::GetDirectoryName($brotliFilePath)
        if(-not (Test-Path -Path $directoryName)) {
            [System.IO.Directory]::CreateDirectory($directoryName) | Out-Null
        }

        try {
            # Create a FileStream for reading the original file
            $fileStream = [System.IO.File]::OpenRead($filePath)

            # Create a FileStream for writing the compressed file
            $brotliStream = [System.IO.File]::Create($brotliFilePath)
 
            # Create a GZipStream for compression, writing to the gzip file
            $brotliWriter = [System.IO.Compression.BrotliStream]::new($brotliStream, [System.IO.Compression.CompressionLevel]::SmallestSize, $false)

            # Copy data from the file stream to the gzip stream
            $fileStream.CopyTo($brotliWriter)

        }
        catch {
            Write-Error "Error compressing file '$filePath': $($Error[0].Message)"
        }
        finally {

            if ($null -ne $brotliWriter) {
                $brotliWriter.Close()
            }

            if ($null -ne $fileStream) {
                $fileStream.Close()
            }

            if($null -ne $brotliStream) {
                $brotliStream.Close()
            }
        }
        $endTime = Get-Date
        $elapsed = New-TimeSpan -Start $using:starttime -End $endTime
        $fileNameOnly = [System.IO.Path]::GetFileName($filePath)
        Write-Progress -Activity "Compressing $fileNameOnly --->" -Status "Elapsed Time: $elapsed"

    }
    $endTime = Get-Date
    $elapsed = New-TimeSpan -Start $using:starttime -End $endTime
    Write-Host "From $source to $destination`n" -ForegroundColor Red -BackgroundColor Cyan
    $PSStyle.Reset
    Write-Progress -Activity "Compression --->" -Status "Complete: $elapsed" -Completed

}
