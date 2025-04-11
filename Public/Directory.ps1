function Get-Tree {
    param()
    try {
        Invoke-Expression 'tree -L 2'
    } catch {
        Write-Error $_
        Write-Error $_.Exception.StackTrace
    }
}