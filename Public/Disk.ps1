function Get-DiskUsage {
    [CmdletBinding()]
    param()


    try {
        # Get disk usage info using df command
        $dfOutput = Invoke-Expression 'df -k --output=source,fstype,size,used,avail,pcent'


        # Split the output into lines
        $lines = $dfOutput -split '\n'


        # Skip the header line
        $lines = $lines[1..($lines.Length - 1)]


        # Create an array to store the disk usage objects
        $diskUsage = @()


        # Iterate over the lines and create disk usage objects
        foreach ($line in $lines) {
            # Split the line into columns
            $columns = $line -split '\s+'


            # Create a disk usage object
            $diskUsageObject = [PSCustomObject]@{
                Source = $columns[0]
                FileSystemType = $columns[1]
                Size = ConvertFrom-Bytes -bytes ([long]$columns[2] * 1024)
                Used = ConvertFrom-Bytes -bytes ([long]$columns[3] * 1024)
                Available = ConvertFrom-Bytes -bytes ([long]$columns[4] * 1024)
                Percent = $columns[5]
            }


            # Add the disk usage object to the array
            $diskUsage += $diskUsageObject
        }


        # Return the disk usage array
        $diskUsage
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