. /home/canute/Develop/PowerNixx/PowerNixx.psd1
. /home/canute/Develop/PowerNixx/Public/Cpu.ps1
while ($true) {
    Get-CpuFromProc -SampleInterval 1 | ConvertTo-Json | Out-File -FilePath /var/log/cpusampler.log -Append
    Start-Sleep -Seconds 10     
}