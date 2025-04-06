Add-PodeRoute -Method Get -Path '/llm/cpu_avg' -ScriptBlock {
    try {
        $ErrorActionPreference = 'Stop'
        $cpuStats = Get-CpuStats
        $averageUsage = ($cpuStats | Measure-Object -Property UsagePercent -Average).Average
        Write-PodeJsonResponse -ContentType 'application/json' -Value @{ 'AverageUsage' = $averageUsage }
    }
    catch {
        Write-PodeLog -Level Error -Message "Error getting CPU average: $($_.Exception.Message)"
        Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Failed to retrieve CPU average: $($_.Exception.Message)" }
    }
}

Add-PodeRoute -Method Get -Path '/llm/cpuinfo' -ScriptBlock {
    try {
        $ErrorActionPreference = 'Stop'
        $cpuStats = Get-CpuStats
        Write-PodeJsonResponse -ContentType 'application/json' -Value $cpuStats
    }
    catch {
        Write-PodeLog -Level Error -Message "Error getting CPU info: $($_.Exception.Message)"
        Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Failed to retrieve CPU info: $($_.Exception.Message)" }
    }
}

Add-PodeRoute -Method Get -Path '/llm/sarcpu' -ScriptBlock {
    try {
        $ErrorActionPreference = 'Stop'
        # If you still need to use sar, consider creating a function in your module
        # that encapsulates the Invoke-Expression call and parses the output.
        # For example:
        $sarOutput = Get-SarCpuStats
        Write-PodeTextResponse -Content 'text/plain' -Value $sarOutput
        #Write-PodeJsonResponse -StatusCode 500 -Value @{ error = 'This route is deprecated.' }
    }
    catch {
        Write-PodeLog -Level Error -Message "Error executing sar -u: $($_.Exception.Message)"
        Write-PodeJsonResponse -StatusCode 500 -Value @{ error = "Failed to retrieve CPU statistics: $($_.Exception.Message)" }
    }
}