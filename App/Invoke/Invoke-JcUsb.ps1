function Invoke-JcUsb {
    return Invoke-Expression lsusb | jc --lsusb | ConvertFrom-Json
}

function Format-JcUsb {
    Invoke-JcUsb | Format-Table -AutoSize -RepeatHeader
}