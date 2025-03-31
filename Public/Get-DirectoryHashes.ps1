<#
.SYNOPSIS
    Recursively hashes each file in a specified directory using a given hash algorithm.

.DESCRIPTION
    The Get-Hash function iterates over all files within a specified directory and its subdirectories.
    It computes the hash of each file using the specified hashing algorithm (default is SHA256) and outputs
    the results to both the console and a specified output file in a table format.

.PARAMETER Path
    The root directory from which to start hashing. This parameter is mandatory.

.PARAMETER Algorithm
    The hashing algorithm to use. Options include MD5, SHA1, SHA256, SHA384, and SHA512.
    Default is 'SHA256'.

.PARAMETER DirectoryHashesFile
    The file path where the hash results will be saved in a table format.

.EXAMPLE
    Get-Hash -Path "C:\Your\Directory\Path" -Algorithm SHA256 -DirectoryHashesFile "C:\Output\hashes.csv"

.NOTES
    This function requires .NET's System.Security.Cryptography for hashing and uses PowerShell cmdlets to handle 
files.
#>

function Get-DirectoryHashes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
        [string]$Algorithm = 'SHA256',

        [Parameter(Mandatory = $false)]
        [string]$DirectoryHashesFile
    )

    # Check if the specified path exists
    if (-Not (Test-Path -Path $Path)) {
        Write-Error "The specified path does not exist: $Path"
        return
    }

    try {
        # Get all files in the directory recursively
        $files = Get-ChildItem -Path $Path -File -Recurse

        # Initialize a list to hold hash results
        $hashResults = @()

        foreach ($file in $files) {
            try {
                # Compute hash of the file
                $hasher = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
                if (-Not $hasher) {
                    Write-Error "The specified algorithm is not available: $Algorithm"
                    return
                }

                $stream = [System.IO.File]::OpenRead($file.FullName)
                try {
                    $hashBytes = $hasher.ComputeHash($stream)
                } finally {
                    $stream.Close()
                }
                
                # Convert hash bytes to a string representation
                $hashString = -join ($hashBytes | ForEach-Object { $_.ToString("x2") })

                # Create a custom object for the result
                $hashResult = [PSCustomObject]@{
                    FilePath  = $file.FullName
                    HashValue = $hashString
                }

                # Add to results list
                $hashResults += $hashResult

            } catch {
                Write-Warning "Failed to hash file: $($file.FullName). Error: $_"
            }
        }

        # Output the results in a table format to the console
        $hashResults | Format-Table -AutoSize

        # If an output file is specified, write the results to it
        if ($DirectoryHashesFile) {
            $hashResults | Export-Csv -Path $DirectoryHashesFile -NoTypeInformation
            Write-Host "Hash results have been written to: $DirectoryHashesFile"
        }

    } catch {
        Write-Error "An error occurred while processing files in directory: $Path. Error: $_"
    }
}
