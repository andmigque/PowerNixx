function Initialize-PsNxCpuSammpler {
    [CmdletBinding()]
    param()
    $subModuleName = 'psnx-cpu-sampler'
    $logFile = "/var/log/$subModuleName.log"
    $serviceFile = "/etc/systemd/system/$subModuleName.service"
    $logrotateFile = "/etc/logrotate.d/$subModuleName"
    $psnxUser = 'psnx'
    $psnxGroup = 'psnx'

    # Ensure psnx group exists
    $groupExists = (Start-Process -FilePath 'getent' -ArgumentList "group $psnxGroup" -NoNewWindow -Wait -PassThru).ExitCode -eq 0
    if (-not $groupExists) {
        Start-Process -FilePath 'sudo' -ArgumentList "groupadd --system $psnxGroup" -Wait
    }
    # Ensure psnx user exists
    $userExists = (Start-Process -FilePath 'getent' -ArgumentList "passwd $psnxUser" -NoNewWindow -Wait -PassThru).ExitCode -eq 0
    if (-not $userExists) {
        Start-Process -FilePath 'sudo' -ArgumentList "useradd --system --gid $psnxGroup --shell /usr/sbin/nologin $psnxUser" -Wait
    }

    # Check if service file exists and stop existing service if running
    Write-Information 'Initializing...'
    if (Test-Path $serviceFile) {
        Start-Process -FilePath 'sudo' -ArgumentList "systemctl stop $subModuleName" -Wait
    }

    # Clean up old log files and create new one
    if (Test-Path $logFile) {
        Write-Information 'Compressing and cleaning up old JSON log file...'
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $gzFile = "$logFile.$timestamp.gz"
        $cmd = "gzip -c $logFile > $gzFile"
        Start-Process -FilePath 'sudo' -ArgumentList 'bash', '-c', $cmd -Wait
        Start-Process -FilePath 'sudo' -ArgumentList "rm $logFile" -Wait
    }

    # Create new log file with correct permissions
    Start-Process -FilePath 'sudo' -ArgumentList "touch $logFile" -Wait
    Start-Process -FilePath 'sudo' -ArgumentList "chown $($psnxUser):$($psnxGroup) $($logFile)" -Wait
    Start-Process -FilePath 'sudo' -ArgumentList "chmod 660 $logFile" -Wait

    # Copy service file
    Write-Information 'Copying service file...'
    Start-Process -FilePath 'sudo' -ArgumentList "cp $PSScriptRoot/$subModuleName.service $serviceFile" -Wait

    # Copy logrotate configuration
    Write-Information 'Setting up log rotation...'
    Start-Process -FilePath 'sudo' -ArgumentList "cp $PSScriptRoot/$subModuleName.logrotate $logrotateFile" -Wait

    # Reload systemd and restart service
    Write-Information 'Reloading systemd and starting service...'
    Start-Process -FilePath 'sudo' -ArgumentList 'systemctl daemon-reload' -Wait
    Start-Process -FilePath 'sudo' -ArgumentList "systemctl restart $subModuleName" -Wait

    Write-Information 'CPU sampler setup completed successfully!'
}