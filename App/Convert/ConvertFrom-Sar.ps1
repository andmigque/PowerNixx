function ConvertFrom-Sar {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Input
    )

    begin {
        $results = @()
    }

    process {
        # If no input is provided, run sar command
        if (-not $Input) {
            $sarOutput = sar
        }
        else {
            $sarOutput = $Input
        }

        # Convert string output to array and remove empty lines
        $lines = $sarOutput -split "`n" | Where-Object { $_ -match '\S' }

        # Parse header for system info
        $systemInfo = $lines[0]
        
        # Skip header lines and process data rows
        $dataLines = $lines | Select-Object -Skip 3 | Where-Object { $_ -notmatch 'Average:' }
        
        foreach ($line in $dataLines) {
            if ($line -match '(\d{2}:\d{2}:\d{2} [AP]M)\s+(\w+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)') {
                $results += [PSCustomObject]@{
                    Time = $matches[1]
                    User     = [double]$matches[3]
                    Nice     = [double]$matches[4]
                    System   = [double]$matches[5]
                    IOWait   = [double]$matches[6]
                    Idle     = [double]$matches[8]
                    
                }
            }
        }
    }

    end {
        $results | Format-Table -AutoSize -RepeatHeader
        return $results | Out-Null
    }
}

# Example usage:
# $sarData = ConvertFrom-Sar
# $sarData | Format-Table
# $sarData | Where-Object { $_.User -gt 20 } | Format-Table