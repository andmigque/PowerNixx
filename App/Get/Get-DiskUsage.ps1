#Checks available disk space and alerts if below a specified threshold.
function Get-DiskUsage {
    [CmdletBinding()]
    param()

    try {
        # Get the list of partitions and their usage statistics
        $DfOut = (df -h)
        Write-Host "PsType: $($DfOut.GetType())"
        $DfOut | ForEach-Object {
            Write-Host "df-line: $($_)"
        }
    }
    catch {
        Write-Error "Failed to check disk space. Error: $_"
    }
}
