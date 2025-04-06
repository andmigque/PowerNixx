function Invoke-Sysctl {
    return sysctl -a | jc --sysctl | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

function Format-SysctlTable {
    Invoke-Sysctl | Format-Table -AutoSize -RepeatHeader
}
