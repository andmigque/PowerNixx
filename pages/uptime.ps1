
Add-PodeRoute -Method Get -Path '/llm/uptime' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'jc /proc/uptime') | Out-String
    Write-PodeJsonResponse -ContentType 'application/json' -Value $unixCommand
}