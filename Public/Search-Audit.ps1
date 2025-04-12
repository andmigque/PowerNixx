using namespace System
using namespace System.Collections

Set-StrictMode -Version 3.0
function Search-Audit {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Directory,
        [Parameter(Mandatory = $true)]
        [string] $SearchString
    )

    # Check for mandatory parameters
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

    $script:startTime = Get-Date

    Write-Progress -Activity "<--- File content search --> " -Status "!! Running !!"
    $allItems = (Get-ChildItem -Path $Directory -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $currentTime = Get-Date
        $differential = ($currentTime - $script:startTime)
        Write-Progress -Activity "Searching" -Status "$differential ⛷"

        if(Test-Path -Path $_.FullName -PathType Leaf -ErrorAction SilentlyContinue){
            if (Select-String -Path $_.FullName -Pattern $script:SearchString -Encoding utf8 -Quiet -ErrorAction SilentlyContinue) {
                $message = "Found $script:SearchString in $($_.FullName)"
                $mutexFound += 1
                return @{
                    Item  = $message
                    Index = $mutexFound.Count
                }
            } else {
                $message = "$script:SearchString was not found in $($_.FullName)"
                $mutexNotFound += 1
                return @{
                    Item = $message
                    Index = $mutexNotFound.Count
                }
            }
        } else {
            $message = "Testing path $($_.FullName) failed)"
            $mutexNotFound += 1
            return @{
                Item = $message
                Index = $mutexNotFound.Count
            }
        }
    })
    Write-Progress -Activity "| File content search___⛷  " -Status "!! Complete !!" -Completed
    Write-Verbose ($allItems | Format-Table -AutoSize -RepeatHeader | Out-String)

    $endTime = Get-Date
    $processingTime = ($endTime - $startTime).TotalSeconds

    $summary = [PSCustomObject]@{
        "Scanned" = $($mutexFound.Count + $mutexNotFound.Count)
        "Found" = $mutexFound.Count
        "Time" = $processingTime
    }
    
    $output = $summary | Format-Table -AutoSize -Property @{
        Name='Scanned';Expression={$_.Scanned};Alignment='Left'
    }, @{
        Name='Found';Expression={$_.Found};Alignment='Left'
    }, @{
        Name='Time';Expression={$_.Time};Alignment='Left'
    } | Out-String
    
    $lines = $output.Split([Environment]::NewLine)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^---') {
            $lines[$i] = '-------------------------'
        }
    }
    
    Write-Host ($lines -join [Environment]::NewLine)
}