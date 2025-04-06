Add-PodeRoute -Method Get -Path '/llm/diskstats' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/diskstats') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}