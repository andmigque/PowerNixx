Add-PodeWebPage -Name 'Log Files' -Icon 'File-Document' -Group 'Logs' -ScriptBlock {
    $logfile = $WebEvent.Query['logfile']

    if([string]::IsNullOrWhiteSpace($logfile)){
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Log Files' -ScriptBlock {
                [LogFileManager]::AddAll()
                $VarLogs = [LogFileManager]::GetAll()
                foreach($Log in $VarLogs) {
                    [ordered]@{
                        Log = New-PodeWebLink -Source "/groups/Logs/pages/Log_Files?logfile=$($Log)" -Value $Log
                    }
                }
            }
        )
    } else {
        $log = (Get-Content -Path "$($logfile)" -Encoding utf8) | ConvertTo-Json
        
        New-PodeWebCard -Name "Log File View" -Content @(
            $log | ConvertFrom-Json | ForEach-Object {
                New-PodeWebText -Value $_
                New-PodeWebLine
            }
        )
    }
    
}
