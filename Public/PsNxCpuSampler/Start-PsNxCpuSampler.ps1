using namespace System.Collections.Generic

$script:logFilePath = '/var/log/psnx-cpu-sampler.log'
# Initialize the log file with an empty array if it doesn't exist
$script:memoryCache = [System.Collections.Generic.List[string]]::new()
function Get-CpuJson {
    Get-CpuFromProc -SampleInterval 1 | ConvertTo-Json -Compress -Depth 3
}

function Get-MemorySamplesCount {
    Write-Information "Memory samples: $($script:memoryCache.Count)"
}
function Write-CpuSamples {
    while ($true) {
        try {
            # Get new CPU data
            $jasonObject = Get-CpuJson
            # Write the JSON object
            Add-Content -Path $script:logFilePath -Value "$($jasonObject)"
            $script:memoryCache.Add($jasonObject)
            if ($script:memoryCache.Count -gt 100) {
                $script:memoryCache.RemoveAt(0)
            }
            Start-Sleep -Seconds 10
        }
        catch {
            Write-Error "Error writing CPU data: $_"
            Start-Sleep -Seconds 1
        }
    }
}

function Show-CpuSamples {
    # Read only the last 100 lines from the log file
    $data = Get-Content -Path $script:logFilePath -Tail 100 | ForEach-Object { $_ | ConvertFrom-Json | Select-Object -ExpandProperty TotalUsage }
    Show-Graph -Datapoints $data -YAxisTitle '%' -XAxisTitle 'samples' -GraphTitle 'CPU Usage' -YAxisStep 3 
}

function Show-LiveCpuSamples {
    while ($true) {
        Clear-Host
        Show-CpuSamples
        Start-Sleep -Seconds 15
    }
}