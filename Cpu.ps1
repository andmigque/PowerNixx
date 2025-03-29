((free -h) -split " ",-1,"Multiline").Trim() | ForEach-Object {
    Write-Host "Line: $($_)"
    (($_).Replace(' ','') -split ":") -split 'Gi'
}