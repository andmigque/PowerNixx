function Set-CronPermissions {
    [CmdletBinding()]
    param()
  
    $CronDirectories = @("/etc/cron.d", "/etc/cron.daily", "/etc/cron.hourly", "/etc/cron.weekly", "/etc/cron.monthly")
  
    foreach ($Directory in $CronDirectories) {
        try {
            # Check if the directory exists
            if (Test-Path -Path $Directory -PathType Container) {
                # Set permissions to 700 (rwx------)
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