[CmdletBinding()]
param()

# Check if service file exists and stop existing service if running
Write-Information "Initializing..."
if (Test-Path /etc/systemd/system/Start-CpuSampler.service) {
    Start-Process -FilePath "sudo" -ArgumentList "systemctl stop Start-CpuSampler" -Wait
}

# Clean up old log file and create new one
if (Test-Path /var/log/cpusampler.log) {
    Write-Information "Cleaning up old log file..."
    Start-Process -FilePath "sudo" -ArgumentList "rm /var/log/cpusampler.log" -Wait
}

# Create new log file with correct permissions
Start-Process -FilePath "sudo" -ArgumentList "touch /var/log/cpusampler.log" -Wait
Start-Process -FilePath "sudo" -ArgumentList "chown canute:canute /var/log/cpusampler.log" -Wait
Start-Process -FilePath "sudo" -ArgumentList "chmod 664 /var/log/cpusampler.log" -Wait

# Copy service file
Write-Information "Copying service file..."
Start-Process -FilePath "sudo" -ArgumentList "cp $PSScriptRoot/Start-CpuSampler.service /etc/systemd/system/" -Wait

# Copy logrotate configuration
Write-Information "Setting up log rotation..."
Start-Process -FilePath "sudo" -ArgumentList "cp $PSScriptRoot/Start-CpuSampler.logrotate /etc/logrotate.d/cpusampler" -Wait

# Reload systemd and restart service
Write-Information "Reloading systemd and starting service..."
Start-Process -FilePath "sudo" -ArgumentList "systemctl daemon-reload" -Wait
Start-Process -FilePath "sudo" -ArgumentList "systemctl restart Start-CpuSampler" -Wait

Write-Information "CPU sampler setup completed successfully!"
