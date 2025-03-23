function df{
    df | jc --df | ConvertFrom-Json | Format-Table -AutoSize -RepeatHeader
}