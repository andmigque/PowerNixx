using namespace System.Collections.Generic
class LogFileManager {
    # Static property to hold the list of log files
    static [List[string]] $LogFiles

    # Static method to initialize the list of log files
    static [void] Initialize() {[LogFileManager]::Initialize($false)}
    static [bool] Initialize([bool]$force) {
        
        if(($null -ne [LogFileManager]::LogFiles) -and ([LogFileManager]::LogFiles.Count -gt 0 -and -not $force)){
            return $false
        }

        [LogFileManager]::LogFiles = [List[string]]::new()
        
        return $true
    }

    # Static method to add a log file path
    static [void] Add([string] $logFilePath) {
        [LogFileManager]::Initialize()
        
        if (-not [string]::IsNullOrWhiteSpace($logFilePath)) {
            if (-not [LogFileManager]::LogFiles.Contains($logFilePath)) {
                [LogFileManager]::LogFiles.Add($logFilePath)
            } else {
                Write-Host "Log file path already exists."
            }
        } else {
            Write-Host "Invalid log file path."
        }
    }

    static [void] AddAll() {
        if ([System.Environment]::OSVersion.Platform.ToString().Contains("Unix")) {
            [LogFileManager]::Initialize()
            
            # Get all directories excluding 'timeshift' directories
            Get-ChildItem -Path '/var/log' -File -Recurse -Force |
            ForEach-Object {
                try {
                    [LogFileManager]::Add("$($_.FullName)")
                } catch {
                    Write-Error $_
                }
                
            }
        }
    }
    
    # Static method to remove a log file path
    static [void] Remove([string] $logFilePath) {
        [LogFileManager]::Initialize()
        if ([LogFileManager]::LogFiles.Contains($logFilePath)) {
            [LogFileManager]::LogFiles.Remove($logFilePath)
        } else {
            Write-Host "Log file path not found."
        }
    }

    # Static method to clear all log files
    static [void] Clear() {
        [LogFileManager]::Initialize()
        [LogFileManager]::LogFiles.Clear()
    }

    # Static method to retrieve all log file paths
    static [string[]] GetAll() {
        [LogFileManager]::Initialize()
        return [LogFileManager]::LogFiles.ToArray()
    }

    # Static method to check if a log file path exists
    static [bool] Contains([string] $logFilePath) {
        [LogFileManager]::Initialize()
        return [LogFileManager]::LogFiles.Contains($logFilePath)
    }
}


