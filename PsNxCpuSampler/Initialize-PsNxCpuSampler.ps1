[CmdletBinding()]
param()

# Check if service file exists and stop existing service if running
Write-Information "Initializing..."
if (Test-Path /etc/systemd/system/psnx-cpu-sampler.service) {
    Start-Process -FilePath "sudo" -ArgumentList "systemctl stop psnx-cpu-sampler" -Wait
}

# Clean up old log files and create new one
if (Test-Path /var/log/psnx-cpu-sampler.json) {
    Write-Information "Cleaning up old JSON log file..."
    Start-Process -FilePath "sudo" -ArgumentList "rm /var/log/psnx-cpu-sampler.json" -Wait
}

# Create new log file with correct permissions
Start-Process -FilePath "sudo" -ArgumentList "touch /var/log/psnx-cpu-sampler.json" -Wait
Start-Process -FilePath "sudo" -ArgumentList "chown canute:canute /var/log/psnx-cpu-sampler.json" -Wait
Start-Process -FilePath "sudo" -ArgumentList "chmod 664 /var/log/psnx-cpu-sampler.json" -Wait

# Copy service file
Write-Information "Copying service file..."
Start-Process -FilePath "sudo" -ArgumentList "cp $PSScriptRoot/psnx-cpu-sampler.service /etc/systemd/system/" -Wait

# Copy logrotate configuration
Write-Information "Setting up log rotation..."
Start-Process -FilePath "sudo" -ArgumentList "cp $PSScriptRoot/psnx-cpu-sampler.logrotate /etc/logrotate.d/psnx-cpu-sampler" -Wait

# Reload systemd and restart service
Write-Information "Reloading systemd and starting service..."
Start-Process -FilePath "sudo" -ArgumentList "systemctl daemon-reload" -Wait
Start-Process -FilePath "sudo" -ArgumentList "systemctl restart psnx-cpu-sampler" -Wait

Write-Information "CPU sampler setup completed successfully!"
