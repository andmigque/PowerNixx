Set-StrictMode -Version 3.0

function Set-CronPermissions {
    [CmdletBinding()]
    param()
  
    $CronDirectories = @("/etc/cron.d", "/etc/cron.daily", "/etc/cron.hourly", "/etc/cron.weekly", "/etc/cron.monthly")
  
    foreach ($Directory in $CronDirectories) {
        try {
            if (Test-Path -Path $Directory -PathType Container) {
                Invoke-Expression "sudo chmod -R 700 $($Directory)"
                Write-Host "Successfully set permissions to 700 for: $Directory"
            }
            else {
                Write-Warning "Directory not found: $Directory"
            }
        }
        catch {
            Write-Error $_
        }
    }
}