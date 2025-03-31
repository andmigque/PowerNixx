function Invoke-Df{
    return df | jc --df | ConvertFrom-Json
}

function Format-DfTable {
    Invoke-Df | Format-Table -AutoSize -RepeatHeader
}