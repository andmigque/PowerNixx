Add-PodeRoute -Method Get -Path '/llm/meminfo' -ScriptBlock {
    $unixCommand = Get-Memory | Select-Object -Property UsedPercent | ConvertTo-Json | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}  