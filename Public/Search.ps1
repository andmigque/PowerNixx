using namespace System
using namespace System.Collections
Set-StrictMode -Version 3.0

function Search-KeywordInFile {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Directory,
        [Parameter(Mandatory = $true)]
        [string] $SearchString
    )

    if ([string]::IsNullOrEmpty($Directory)) {
        throw 'Error: Directory can not be empty.'
    }
    if ([string]::IsNullOrEmpty($SearchString)) {
        throw 'Error: SearchString can not be empty.'
    }

    $Directory = Resolve-Path -Path $Directory
    $SearchString = $SearchString.Trim()
    $startTime = Get-Date

    Write-Progress -Activity '<--- File content search -->' -Status '!! Running !!'

    $allItems = Get-ChildItem -Path $Directory -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object -Parallel {
        $localSearchString = $using:SearchString
        $fullName = $_.FullName
        
        $found = $false
        try {
            if ($localSearchString -eq $_.FullName.ToLower().Trim()) {
                $found = $true
            }
            elseif (Test-Path -Path $_.FullName -PathType Leaf -ErrorAction SilentlyContinue) {
                if (Select-String -Path $_.FullName -Pattern $localSearchString -Encoding utf8 -Quiet -ErrorAction SilentlyContinue) {
                    $found = $true
                }
            }
        }
        catch {
            # Optionally add error info
        }
        return @{
            File  = $fullName
            Found = $found
        }
    }

    Write-Progress -Activity '| File content search___⛷  ' -Status '!! Complete !!' -Completed

    $foundFiles = $allItems | Where-Object { $_.Found }
    $endTime = Get-Date
    $processingTime = ($endTime - $startTime).TotalSeconds

    $summary = [PSCustomObject]@{
        Scanned = $allItems.Count
        Found   = $foundFiles.Count
        Time    = $processingTime
        Files   = $foundFiles.File
    }

    $summary | ConvertTo-Json -Depth 3 -Compress
}