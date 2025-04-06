Add-PodeRoute -Method Get -Path '/llm/securerandom' -ScriptBlock {
    $random1 = Get-SecureRandom
    $random2 = Get-SecureRandom
    Write-PodeJsonResponse -Value @{ 'random1' = $random1; 'random2' = $random2 }
}