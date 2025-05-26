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
        throw 'Error: Directory parameter cannot be null or empty.'
    }
    if ([string]::IsNullOrEmpty($SearchString)) {
        throw "Error: SearchString parameter for directory '$Directory' cannot be null or empty."
    }

    $script:Directory = Resolve-Path -Path $Directory
    $script:SearchString = $SearchString.Trim()

    
    [ArrayList]$mutexFound = [ArrayList]::Synchronized(@())
    [ArrayList]$mutexNotFound = [ArrayList]::Synchronized(@())
    [ArrayList]$mutexFilesFound = [ArrayList]::Synchronized(@())
    [ArrayList]$mutexFilenameFound = [ArrayList]::Synchronized(@())

    $script:startTime = Get-Date

    Write-Progress -Activity '<--- File content search --> ' -Status '!! Running !!'
    $allItems = (Get-ChildItem -Path $Directory -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $currentTime = Get-Date
            $differential = ($currentTime - $script:startTime)
            Write-Progress -Activity 'Searching' -Status "$differential ⛷"

            if ($script:SearchString.ToLower().Trim() -eq $($_).FullName.ToLower().Trim()) {
                $mutexFilenameFound += "$($_.FullName)"
                $mutexFound += 1
            }
            
            if (Test-Path -Path $_.FullName -PathType Leaf -ErrorAction SilentlyContinue) {
                if (Select-String -Path $_.FullName -Pattern $script:SearchString -Encoding utf8 -Quiet -ErrorAction SilentlyContinue) {
                    $message = "Found $script:SearchString in $($_.FullName)"
                    Write-Verbose $message
                    $mutexFilesFound += "$($_.FullName)"
                    $mutexFound += 1
                    return @{
                        Item  = $message
                        Index = $mutexFound.Count
                    }
                }
                else {
                    $message = "$script:SearchString was not found in $($_.FullName)"
                    $mutexNotFound += 1
                    return @{
                        Item  = $message
                        Index = $mutexNotFound.Count
                    }
                }
            }
            else {
                $message = "Testing path $($_.FullName) failed)"
                $mutexNotFound += 1
                return @{
                    Item  = $message
                    Index = $mutexNotFound.Count
                }
            }
        })
    Write-Progress -Activity '| File content search___⛷  ' -Status '!! Complete !!' -Completed
    Write-Verbose ($allItems | Format-Table -AutoSize -RepeatHeader | Out-String)

    $endTime = Get-Date
    $processingTime = ($endTime - $startTime).TotalSeconds

    $summary = [PSCustomObject]@{
        'Scanned' = $($mutexFound.Count + $mutexNotFound.Count)
        'Found'   = $mutexFound.Count
        'Time'    = $processingTime
        'Files'   = $mutexFilesFound
    }

    Write-Verbose ($summary | Format-Table -AutoSize -RepeatHeader | Out-String -Width 100) 

    return $summary
    
}