function Invoke-Sysctl {
    sysctl -a  | jc --sysctl | ConvertFrom-Json
}

function Format-SysctlTable {
    Invoke-Sysctl | Format-Table -AutoSize -RepeatHeader
}