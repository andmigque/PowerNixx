function Remove-Spaces{
    param([string]$line)
    return $line.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
}