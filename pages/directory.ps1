Add-PodeRoute -Method Get -Path '/llm/self/tree' -ScriptBlock {
    $unixCommand = (Invoke-Expression 'tree -L 2') | Out-String
    Write-PodeJsonResponse -ContentType 'text/plain' -Value $unixCommand
}