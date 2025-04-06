Add-PodeRoute -Method Get -Path '/llm/self/ps' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'ps aux | grep "text-generation-webui"') | Out-String
    Write-PodeJsonResponse -ContentType 'text/plain' -Value $unixCommand
}