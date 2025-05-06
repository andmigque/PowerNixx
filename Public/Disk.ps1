function Get-DiskUsage {
    [CmdletBinding()]
    param()
    
    try {
        $dfOutput = Invoke-Expression 'df -k --output=target,fstype,size,used,avail,pcent'
        $lines = $dfOutput -split '\n'
        
        $lines = $lines[1..($lines.Length - 1)]
        
        $diskUsage = @()
        
        foreach ($line in $lines) {
            $columns = $line -split '\s+'
            
            $diskUsageObject = [PSCustomObject]@{
                Source         = $columns[0]
                FileSystemType = $columns[1]
                Size           = [ByteMapper]::ConvertFromBytes([long]$columns[2] * 1024)
                Used           = [ByteMapper]::ConvertFromBytes([long]$columns[3] * 1024)
                Available      = [ByteMapper]::ConvertFromBytes([long]$columns[4] * 1024)
                Percent        = $columns[5]
            }
            
            $diskUsage += $diskUsageObject
        }

        return $diskUsage
    }
    catch {
        Write-Error $_
        return [PSCustomObject]@{
            Error = $_.Exception.Message
        }
    }
}

function Format-DiskUsage {
    param()

    Get-DiskUsage | Select-Object @{
        Name       = 'Device' 
        Expression = { $_.Source }
    }, @{
        Name       = 'Type' 
        Expression = { $_.FileSystemType }
    }, @{
        Name       = 'Total' 
        Expression = { '{0:N2} {1}' -f $_.Size.HumanBytes, $_.Size.Unit }
    }, @{
        Name       = 'Used' 
        Expression = { '{0:N2} {1}' -f $_.Used.HumanBytes, $_.Used.Unit }
    }, @{
        Name       = 'Available' 
        Expression = { '{0:N2} {1}' -f $_.Available.HumanBytes, $_.Available.Unit }
    }, @{
        Name       = 'Used%' 
        Expression = { '{0:N1}' -f $_.Percent }
    } | Format-Table -AutoSize
}

function Invoke-JcUsb {
    return Invoke-Expression 'lsusb | jc --lsusb' | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

function Format-JcUsb {
    Invoke-JcUsb | Format-Table -AutoSize -RepeatHeader
}

function Invoke-Df {
    return df | jc --df | 
        ConvertFrom-Json | 
        ConvertTo-Json
}

function Format-Df {
    Invoke-Df | Format-Table -AutoSize -RepeatHeader
}

# Define a function to execute iostat and parse the output
function Get-DiskIO {
    try {
        return ((iostat -d --human -o JSON) | ConvertFrom-Json).sysstat.hosts.statistics.disk | ForEach-Object {
            $device = $_.disk_device
            $transactionsPerSecond = $_.tps
            $bytesReadPerSec = ($_.'kB_read/s') * 1024
            $bytesWrittenPerSec = ($_.'kB_wrtn/s') * 1024
            $bytesDiscardedPerSec = ($_.'kB_dscd/s') * 1024
            $bytesRead = ($_.'kB_read') * 1024
            $bytesWritten = ($_.'kB_wrtn') * 1024
            $bytesDiscarded = ($_.'kB_dscd') * 1024
            
            return [PSCustomObject]@{
                Device                = $device
                TransactionsPerSecond = $transactionsPerSecond # Assuming TPS is just a number, not bytes
                BytesReadPerSec       = [ByteMapper]::ConvertFromBytes($bytesReadPerSec)
                BytesWrittenPerSec    = [ByteMapper]::ConvertFromBytes($bytesWrittenPerSec)
                BytesDiscardedPerSec  = [ByteMapper]::ConvertFromBytes($bytesDiscardedPerSec)
                BytesRead             = [ByteMapper]::ConvertFromBytes($bytesRead)
                BytesWritten          = [ByteMapper]::ConvertFromBytes($bytesWritten)
                BytesDiscarded        = [ByteMapper]::ConvertFromBytes($bytesDiscarded)
            }
        }
    }
    catch {
        Write-Host "Error processing iostat output: $_"
    }
}

function Format-DiskIO {
    Get-DiskIO | Format-Table -AutoSize -RepeatHeader
}