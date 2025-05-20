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
    
    The function uses parallel processing for improved performance.
    It provides real-time progress updates with elapsed time and a ski emoji (⛷) indicator.

    .PARAMETER SourceDirectory
    The source directory containing files to compress. Must be an existing directory path.

    .PARAMETER DestinationDirectory
    The destination directory where compressed files will be saved. If it doesn't exist, it will be created.

    .INPUTS
    System.String
    Accepts two string parameters: SourceDirectory and DestinationDirectory

    .OUTPUTS
    None
    The function does not return any output but may create a CompressionErrors.json file
    in the destination directory if any files fail to compress

    .EXAMPLE
    ConvertTo-GzipParallel -SourceDirectory "/var/log" -DestinationDirectory "/backup/logs"

    .EXAMPLE
    ConvertTo-GzipParallel -SourceDirectory "/home/user/documents" -DestinationDirectory "./compressed/docs"

    .NOTES
    - Uses parallel processing for improved performance
    - Creates a CompressionErrors.json file in the destination directory if any files fail to compress
    - Maintains original directory structure in destination directory
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,

        [Parameter(Mandatory = $true)]
        [string]$DestinationDirectory
    )

    if (-not (Test-Path -Path $SourceDirectory -PathType Container)) {
        throw "Source directory '$SourceDirectory' does not exist."
    }

    if (-not (Test-Path -Path $DestinationDirectory)) {
        Write-Information "Destination directory '$DestinationDirectory' does not exist. Creating..."
        New-Item -Path $DestinationDirectory -ItemType Directory -Force | Out-Null
    }

    $ParallelErrors = [ConcurrentDictionary[string, string]]::new()

    $startTime = Get-Date

    $files = Get-ChildItem -Path $SourceDirectory -Recurse -File -ErrorAction SilentlyContinue
    Write-Information "Files found: $($files.Count)"

    $files | ForEach-Object -Parallel {
        $errors = $using:ParallelErrors
        $currentTime = Get-Date
        $elapsedTime = [string]::Format('{0:hh\:mm\:ss}', ($currentTime - $using:startTime))
        Write-Progress -Activity 'Compressing' -Status "$elapsedTime ⛷"

        $filePath = $_.FullName
        $relativePath = $_.FullName.Substring($using:SourceDirectory.Length).TrimStart('\', '/')
        $destPath = Join-Path -Path $using:DestinationDirectory -ChildPath $relativePath
        $destDir = [System.IO.Path]::GetDirectoryName($destPath)

        if (-not (Test-Path -Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory -Force | Out-Null
        }
        $gzipFilePath = "$destPath.gz"

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
            Out-File -FilePath "$DestinationDirectory/CompressionErrors.json"
        Write-Warning "Some files failed to compress. See $DestinationDirectory/CompressionErrors.json for details."
    }
    else {
        Write-Host 'Compression complete'
    }
}