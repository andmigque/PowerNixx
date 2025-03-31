function Get-PsHistory {
    param()
    (Get-PSReadLineOption).HistorySavePath
    Get-Content -Path (Get-PSReadLineOption).HistorySavePath
}
