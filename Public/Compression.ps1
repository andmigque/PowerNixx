Set-StrictMode -Version 3.0

function ConvertTo-GzipParallel {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SrcDir,

        [Parameter(Mandatory = $true)]
        [string]$DestDir
    )
    $script:ParallelErrors = @()
    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = $DestDir

    # Check if source and destination directories exist
    if (-not (Test-Path -Path $source)) {
        throw "Source directory '$source' does not exist."
    }

    if (-not (Test-Path -Path $destination)) {
        Write-Information "Destination directory '$destination' does not exist. Creating..."
        New-Item -Path $destination -ItemType Directory -Force -Confirm | Out-Null
    }
    $startTime = Get-Date
    $items = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object -Parallel {

        $currentTime = (Get-Date)
        $beginTime = $using:startTime

        $differential = ($currentTime - $beginTime)
        $differential = [string]::Format("{0:hh\:mm\:ss}", $differential)
        Write-Progress -Activity 'Compressing' -Status "$differential ⛷"

        $filePath = $_.FullName
        $baseName = $_.Name
        $extension = $_.Extension
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
            $script:ParallelErrors += $_
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

    

    if($script:ParallelErrors.Count -gt 0) {
       $parallelErrorsJason = $script:ParallelErrors | ConvertTo-Json -Depth 10
    } else {
        Write-Host "Compression complete"
    }
}