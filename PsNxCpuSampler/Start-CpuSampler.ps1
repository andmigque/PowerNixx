using namespace System.Collections.Generic

. /home/canute/Develop/PowerNixx/PowerNixx.psd1
. /home/canute/Develop/PowerNixx/Public/Cpu.ps1

$script:logFilePath = '/var/log/psnx-cpu-sampler.json'
# Initialize the log file with an empty array if it doesn't exist
$memoryCache = [System.Collections.Generic.List[string]]::new()

function Write-PsNxCpuSamplerLog {

}

function Get-CpuJson {
    Get-CpuFromProc -SampleInterval 1 | ConvertTo-Json | Out-String
}
while ($true) {
    try {
        # Get new CPU data
        $jasonObject = Get-CpuJson
        
        
        
        
        # Write the JSON object
        $jasonObject | Out-File -FilePath $script:logFilePath -Encoding utf8 -Append
        
        # Store current object as previous for next iteration
        $previousJasonObject = $jasonObject
        Start-Sleep -Seconds 10
    }
    catch {
        Write-Error "Error writing CPU data: $_"
        Start-Sleep -Seconds 1
    }
}