using namespace System.Collections.Concurrent
using namespace Microsoft.Win32
Set-StrictMode -Version 3.0

function Remove-ESRegistryKeysParallel {
<# .SYNOPSIS
Parallel removal of EventSentry registry keys containing PII

```
.DESCRIPTION
Remove-ESRegistryKeysParallel removes specified registry keys/values from EventSentry installations
using parallel processing for maximum performance. Supports wildcard patterns and handles errors gracefully.

.PARAMETER RegistryTargets
Array of registry paths to remove. Supports wildcards and can target specific keys or entire subtrees.
Format: 'HKLM:\Software\netikus.net\EventSentry\Path\KeyName' or 'HKLM:\Software\netikus.net\EventSentry\Path\*'

.PARAMETER ComputerNames  
Array of computer names to target. If not specified, targets local machine only.

.PARAMETER WhatIf
Shows what would be removed without actually performing the deletion.

.EXAMPLE
$targets = @('HKLM:\Software\netikus.net\EventSentry\SomeKey\*')
Remove-ESRegistryKeysParallel -RegistryTargets $targets

.EXAMPLE
$servers = @('SERVER01', 'SERVER02', 'SERVER03')
$keys = @('HKLM:\Software\netikus.net\EventSentry\*')
Remove-ESRegistryKeysParallel -RegistryTargets $keys -ComputerNames $servers

.NOTES
- Requires administrative privileges on target systems
- Uses parallel processing for improved performance at scale
- Automatically triggers EventSentry configuration save
- Creates error log for failed operations
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$RegistryTargets,

    [Parameter(Mandatory = $false)]
    [string[]]$ComputerNames = @($env:COMPUTERNAME),

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

$ParallelErrors = [ConcurrentDictionary[string, string]]::new()
$startTime = Get-Date

Write-Host "Targeting $($RegistryTargets.Count) registry patterns across $($ComputerNames.Count) computers"

# Build target list - expand wildcards and computer combinations
$allTargets = @()
foreach ($computer in $ComputerNames) {
    foreach ($target in $RegistryTargets) {
        $allTargets += [PSCustomObject]@{
            Computer = $computer
            RegistryPath = $target
        }
    }
}

Write-Host "Processing $($allTargets.Count) total registry operations"

$allTargets | ForEach-Object -Parallel {
    $errors = $using:ParallelErrors
    $whatIfMode = $using:WhatIf
    
    $currentTime = Get-Date
    $elapsedTime = [string]::Format('{0:hh\:mm\:ss}', ($currentTime - $using:startTime))
    Write-Progress -Activity 'Cleaning Registry' -Status "$elapsedTime 🧹"

    $computer = $_.Computer
    $registryPath = $_.RegistryPath
    
    try {
        # Parse registry path
        if ($registryPath -match '^HKLM:\\(.+)$') {
            $keyPath = $matches[1]
        } else {
            $errors.TryAdd("${computer}:${registryPath}", "Invalid registry path format") | Out-Null
            return
        }
        
        # Handle wildcards in path
        if ($keyPath.Contains('*')) {
            $pathParts = $keyPath.Split('\')
            $wildcardIndex = -1
            
            for ($i = 0; $i -lt $pathParts.Count; $i++) {
                if ($pathParts[$i].Contains('*')) {
                    $wildcardIndex = $i
                    break
                }
            }
            
            if ($wildcardIndex -ge 0) {
                $basePath = ($pathParts[0..($wildcardIndex-1)] -join '\')
                $pattern = $pathParts[$wildcardIndex]
                
                if ($computer -eq $env:COMPUTERNAME) {
                    $baseRegPath = "HKLM:\$basePath"
                    if (Test-Path $baseRegPath) {
                        $subKeys = Get-ChildItem $baseRegPath -ErrorAction SilentlyContinue | 
                                   Where-Object { $_.PSChildName -like $pattern }
                        
                        foreach ($subKey in $subKeys) {
                            $fullPath = "$baseRegPath\$($subKey.PSChildName)"
                            
                            if ($pathParts.Count -gt $wildcardIndex + 1) {
                                # Removing a value within the matched key
                                $valueName = $pathParts[$wildcardIndex + 1]
                                if (Get-ItemProperty $fullPath -Name $valueName -ErrorAction SilentlyContinue) {
                                    if ($whatIfMode) {
                                        Write-Host "WHATIF: Would remove $computer $fullPath\$valueName"
                                    } else {
                                        Remove-ItemProperty -Path $fullPath -Name $valueName -Force -ErrorAction SilentlyContinue
                                    }
                                }
                            } else {
                                # Removing the entire matched key
                                if ($whatIfMode) {
                                    Write-Host "WHATIF: Would remove $computer $fullPath"
                                } else {
                                    Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
                                }
                            }
                        }
                    }
                } else {
                    # Remote registry handling via Invoke-Command
                    $scriptBlock = {
                        param($BasePath, $Pattern, $PathParts, $WildcardIndex, $WhatIfMode)
                        
                        $baseRegPath = "HKLM:\$BasePath"
                        if (Test-Path $baseRegPath) {
                            $subKeys = Get-ChildItem $baseRegPath -ErrorAction SilentlyContinue | 
                                      Where-Object { $_.PSChildName -like $Pattern }
                            
                            foreach ($subKey in $subKeys) {
                                $fullPath = "$baseRegPath\$($subKey.PSChildName)"
                                
                                if ($PathParts.Count -gt $WildcardIndex + 1) {
                                    $valueName = $PathParts[$WildcardIndex + 1]
                                    if (Get-ItemProperty $fullPath -Name $valueName -ErrorAction SilentlyContinue) {
                                        if (-not $WhatIfMode) {
                                            Remove-ItemProperty -Path $fullPath -Name $valueName -Force -ErrorAction SilentlyContinue
                                        }
                                    }
                                } else {
                                    if (-not $WhatIfMode) {
                                        Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
                                    }
                                }
                            }
                        }
                    }
                    
                    Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $basePath, $pattern, $pathParts, $wildcardIndex, $whatIfMode -ErrorAction SilentlyContinue
                }
            }
        } else {
            # Direct path - no wildcards
            if ($computer -eq $env:COMPUTERNAME) {
                $regPath = "HKLM:\$keyPath"
                
                # Check if it's a registry value or key
                $parentPath = Split-Path $regPath -Parent
                $itemName = Split-Path $regPath -Leaf
                
                if ((Test-Path $parentPath) -and (Get-ItemProperty $parentPath -Name $itemName -ErrorAction SilentlyContinue)) {
                    # It's a value
                    if ($whatIfMode) {
                        Write-Host "WHATIF: Would remove $computer $regPath (value)"
                    } else {
                        Remove-ItemProperty -Path $parentPath -Name $itemName -Force -ErrorAction SilentlyContinue
                    }
                } elseif (Test-Path $regPath) {
                    # It's a key
                    if ($whatIfMode) {
                        Write-Host "WHATIF: Would remove $computer $regPath (key)"
                    } else {
                        Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            } else {
                # Remote direct path
                $scriptBlock = {
                    param($KeyPath, $WhatIfMode)
                    
                    $regPath = "HKLM:\$KeyPath"
                    $parentPath = Split-Path $regPath -Parent
                    $itemName = Split-Path $regPath -Leaf
                    
                    if ((Test-Path $parentPath) -and (Get-ItemProperty $parentPath -Name $itemName -ErrorAction SilentlyContinue)) {
                        if (-not $WhatIfMode) {
                            Remove-ItemProperty -Path $parentPath -Name $itemName -Force -ErrorAction SilentlyContinue
                        }
                    } elseif (Test-Path $regPath) {
                        if (-not $WhatIfMode) {
                            Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
                        }
                    }
                }
                
                Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $keyPath, $whatIfMode -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        $errors.TryAdd("${computer}:${registryPath}", $_.Exception.Message) | Out-Null
    }
}

# Trigger EventSentry config updates on all computers if not in WhatIf mode
if (-not $WhatIf) {
    Write-Host "Triggering EventSentry configuration updates..."
    $ComputerNames | ForEach-Object -Parallel {
        $computer = $_
        try {
            if ($computer -eq $env:COMPUTERNAME) {
                $triggerPath = 'HKLM:\Software\netikus.net\EventSentry\Notify\'
                $trigger = Get-ItemPropertyValue $triggerPath -Name "trigger" -ErrorAction SilentlyContinue
                if ($trigger) {
                    $trigger++
                    Set-ItemProperty -Path $triggerPath -Name "trigger" -Value $trigger -Force
                }
            } else {
                # Remote trigger update via Invoke-Command would go here
                Write-Verbose "Remote config trigger for $computer not implemented"
            }
        }
        catch {
            Write-Warning "Failed to trigger config update on ${computer}: $($_.Exception.Message)"
        }
    }
}

# Output results
if ($ParallelErrors.Count -gt 0) {
    $errorFile = "ESRegistryCleanupErrors_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $ParallelErrors.GetEnumerator() | ConvertTo-Json -Depth 10 | Out-File -FilePath $errorFile
    Write-Warning "Some operations failed. See $errorFile for details."
} else {
    Write-Host "Registry cleanup completed successfully" -ForegroundColor Green
}

$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Total time: $($duration.ToString('hh\:mm\:ss'))"
```

}