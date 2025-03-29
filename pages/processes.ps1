Add-PodeWebPage -Name 'Processes' -Icon 'Settings' -Group 'System' -ScriptBlock {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name 'Processes' -ScriptBlock {
            
            $Processes = (Get-Process -IncludeUserName ) | `
            Select-Object -Unique -Property Id, `
            WorkingSet, ProcessName, UserName, `
            @{Name="CommandLine";Expression={("$($_.CommandLine)".Length -le 50) `
            ? "$($_.CommandLine)" : ("$($_.CommandLine)".Substring(0,50)) + "..." }}| `
            Sort-Object -Descending WorkingSet -Top 30
            
            foreach ($Ps in ($Processes)) {
                [ordered]@{
                    Id   = $Ps.Id
                    Memory = $Ps.WorkingSet
                    Name = $Ps.ProcessName
                    User = $Ps.UserName
                    Cmd = $Ps.CommandLine
                }
            }
        }
    )
}