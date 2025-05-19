using namespace System.Collections.Concurrent
using namespace System.IO.Compression
using namespace System.IO
Set-StrictMode -Version 3.0

function ConvertTo-GzipParallel {
    <# .SYNOPSIS
    Parallel compression of files using .NET native GZip streams

    .DESCRIPTION
    ConvertTo-GzipParallel compresses files from a source directory to a destination directory using parallel processing. 
    It utilizes GZip compression with the smallest size level and provides progress tracking during compression. 
    The function handles errors gracefully by storing them in a JSON file and can process files recursively.
    
    The function uses parallel processing for improved performance and provides real-time progress updates with elapsed time and a ski emoji (⛷) indicator.

    .PARAMETER SrcDir
    The source directory containing files to compress. Must be an existing directory path.

    .PARAMETER DestDir
    The destination directory where compressed files will be saved. If it doesn't exist, it will be created.

    .INPUTS
    System.String
    Accepts two string parameters: SrcDir and DestDir

    .OUTPUTS
    None
    The function does not return any output but may create a CompressionErrors.json file
    in the destination directory if errors occur.

    .EXAMPLE
    ConvertTo-GzipParallel -SrcDir "C:\Data\Input" -DestDir "C:\Data\Output"
    Compresses all files from the input directory to the output directory using parallel processing.

    .EXAMPLE
    ConvertTo-GzipParallel -SrcDir "C:\LargeDataset" -DestDir "C:\CompressedData"
    Compresses files from a large dataset directory using parallel processing.

    .NOTES
    - Uses parallel processing for improved performance
    - Creates a CompressionErrors.json file in the destination directory if any files fail to compress
    - Maintains original file structure in destination directory # TODO: This isn't true
    - Uses GZip compression with smallest size level
    - Progress is tracked and displayed with elapsed time and a ski emoji (⛷) indicator
    - Implements proper resource cleanup using try/catch/finally blocks
    - Uses thread-safe ConcurrentDictionary for error collection

    .LINK
    https://github.com/PowerShell/platyPS

    .LINK
    https://github.com/andmigque/powernixx

    .LINK    
    https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.gzipstream?view=net-9.0
    
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SrcDir,

        [Parameter(Mandatory = $true)]
        [string]$DestDir
    )

    $ParallelErrors = [ConcurrentDictionary[string, string]]::new()
    $source = (Resolve-Path -Path $SrcDir).Path
    $destination = (Resolve-Path -Path $DestDir).Path

    Write-Information "Source: $source"
    Write-Information "Destination: $destination"

    if (-not (Test-Path -Path $source)) {
        throw "Source directory '$source' does not exist."
    }

    if (-not (Test-Path -Path $destination)) {
        Write-Information "Destination directory '$destination' does not exist. Creating..."
        New-Item -Path $destination -ItemType Directory -Force -Confirm | Out-Null
    }

    $startTime = Get-Date

    $files = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue
    Write-Information "Files found: $($files.Count)"

    $files | ForEach-Object -Parallel {
        $errors = $Using:ParallelErrors
        $currentTime = Get-Date
        $elapsedTime = [string]::Format('{0:hh\:mm\:ss}', ($currentTime - $using:startTime))
        Write-Progress -Activity 'Compressing' -Status "$elapsedTime ⛷"

        $filePath = $_.FullName
        $baseName = $_.Name
        $gzipFilePath = Join-Path -Path $using:destination -ChildPath "$baseName.gz"

        try {
            $fileStream = [System.IO.File]::OpenRead($filePath)
            $gzipStream = [System.IO.File]::Create($gzipFilePath)
            $gzipWriter = [System.IO.Compression.GZipStream]::new($gzipStream, [System.IO.Compression.CompressionLevel]::SmallestSize, $false)
            $fileStream.CopyTo($gzipWriter)
        }
        catch {
            $errors.TryAdd($filePath, $_.Exception.Message) | Out-Null
        }
        finally {
            if ($null -ne $gzipWriter) {
                $gzipWriter.Close()
            }

            if ($null -ne $fileStream) {
                $fileStream.Close()
            }
        }
    }

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