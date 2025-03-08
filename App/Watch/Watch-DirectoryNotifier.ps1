function Watch-DirectoryNotifier {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProjectProfileDir,

        [Parameter(Mandatory = $false)]
        [string]$LogFile = "DirectoryChanges.log"
    )

    # Ensure the directory exists
    if (-Not (Test-Path -Path $ProjectProfileDir)) {
        Write-Error "The specified directory '$ProjectProfileDir' does not exist."
        return
    }

    $Watcher = New-Object System.IO.FileSystemWatcher

    try {
        # Setup watcher
        $Watcher.Path = $ProjectProfileDir
        $Watcher.NotifyFilter = [IO.NotifyFilters]'LastWrite, Size, Attributes'

        Register-ObjectEvent -InputObject $Watcher -EventName Changed -SourceIdentifier "FileChanged" -Action {
            param(
                [string]$LogFile
            )
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            try {
                # Log the change to a file
                $logMessage = "$($timestamp): Change detected in $($Watcher.Path)"
                Add-Content -Path $using:LogFile -Value $logMessage

            } catch {
                # Log errors to file and console
                $errorMessage = $_.Exception.Message
                Add-Content -Path $LogFile -Value "$($timestamp): Error occurred - $errorMessage"
            }
        }
    } catch {
        Write-Error "Failed to set up directory watcher: $_"
    }

    Write-Host "Watching for changes in '$ProjectProfileDir'. Logging to '$LogFile'."
}