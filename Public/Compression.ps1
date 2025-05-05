using namespace System.Collections.Concurrent
using namespace System.IO.Compression
using namespace System.IO
Set-StrictMode -Version 3.0

function ConvertTo-GzipParallel {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SrcDir,

        [Parameter(Mandatory = $true)]
        [string]$DestDir
    )

    # Use a thread-safe ConcurrentDictionary for error collection
    $ParallelErrors = [ConcurrentDictionary[string, string]]::new()
    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    # Debug: Verify paths
    Write-Information "Source: $source"
    Write-Information "Destination: $destination"

    # Ensure source and destination directories exist
    if (-not (Test-Path -Path $source)) {
        throw "Source directory '$source' does not exist."
    }

    if (-not (Test-Path -Path $destination)) {
        Write-Information "Destination directory '$destination' does not exist. Creating..."
        New-Item -Path $destination -ItemType Directory -Force -Confirm | Out-Null
    }

    $startTime = Get-Date

    # Debug: Check files found
    $files = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue
    Write-Information "Files found: $($files.Count)"

    # Process files in parallel
    $files | ForEach-Object -Parallel {
        $errors = $Using:ParallelErrors
        $currentTime = Get-Date
        $elapsedTime = [string]::Format('{0:hh\:mm\:ss}', ($currentTime - $using:startTime))
        Write-Progress -Activity 'Compressing' -Status "$elapsedTime ⛷"

        $filePath = $_.FullName
        $baseName = $_.Name
        $gzipFilePath = Join-Path -Path $using:destination -ChildPath "$baseName.gz"

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
            # Add errors to the thread-safe ConcurrentDictionary and log them
            $errors.TryAdd($filePath, $_.Exception.Message) | Out-Null
            #Write-Host "Error compressing file: $filePath - $_"
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

    # Handle errors
    if ($ParallelErrors.Count -gt 0) {
        $ParallelErrors.GetEnumerator() | 
            ConvertTo-Json -Depth 10 | 
            Out-File -FilePath "$destination/CompressionErrors.json"
        Write-Warning "Some files failed to compress. See $($destination)/CompressionErrors.json for details."
    }
    else {
        Write-Host 'Compression complete'
    }
}