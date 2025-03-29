Get-Job | ForEach-Object { 
    Stop-Job $_  
    Remove-Job $_ 
}