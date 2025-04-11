
class ByteMapperClazz {
    [double]$KiloBytes = 1024
    [double]$MegaBytes = 1024 * 1024
    [double]$GigaBytes = 1024 * 1024 * 1024
    [double]$TeraBytes = 1024 * 1024 * 1024 * 1024
    [double]$PetaBytes = 1024 * 1024 * 1024 * 1024 * 1024

    [double]$HumanBytes = 0
    [double]$OriginalBytes = 0
    [double]$NumeratorBytes = 0 
    [double]$DenominatorBytes = 1
    [double]$Percent = 0
    [string]$Unit = 'B'

    ByteMapperClazz([double]$bytes) {
        $this.OriginalBytes = $bytes    
    }

    [PsCustomObject]ConvertFromBytes([double]$bytes) {
        if ($bytes -lt 0) {
            return [PSCustomObject]@{
                Error = "Bytes cannot be negative: $bytes"
            }
        }

        # Create new mapper instance from template
        $byteMapper = [PSCustomObject]$script:BYTE_MAPPER_TEMPLATE.Clone()
        $byteMapper.OriginalBytes = $bytes

        try {
            # Order from largest to smallest for correct conversion
            if ($bytes -ge $this.TeraBytes) {
                $byteMapper.HumanBytes = ($bytes / $this.TeraBytes)
                $byteMapper.Unit = 'TB'
            }
            elseif ($bytes -ge $this.PetaBytes) {
                $byteMapper.HumanBytes = ($bytes / $this.PetaBytes)
                $byteMapper.Unit = 'PB'
            }
            elseif ($bytes -ge $this.GigaBytes) {
                $byteMapper.HumanBytes = ($bytes / $this.GigaBytes)
                $byteMapper.Unit = 'GB'
            }
            elseif ($bytes -ge $this.MegaBytes) {
                $byteMapper.HumanBytes = ($bytes / $this.MegaBytes)
                $byteMapper.Unit = 'MB'
            }
            elseif ($bytes -ge $this.KiloBytes) {
                $byteMapper.HumanBytes = ($bytes / $this.KiloBytes)
                $byteMapper.Unit = 'KB'
            }
            else {
                $byteMapper.HumanBytes = $bytes
                $byteMapper.Unit = 'B'
            }

            return $byteMapper
        }
        catch {
            Write-Error $_
            return [PSCustomObject]@{
                Error = $_.Exception.Message
            }
        }
    }

    
    [PsCustomObject]ConvertToPercent([double]$numerator, [double]$denominator,[int]$decimalPlaces = 2) {

        # Create new mapper instance from template
        $percentMapper = [PSCustomObject]$script:PERCENT_MAPPER_TEMPPLATE.Clone()
        
        try {
            # Check for division by zero
            if ($denominator -eq 0) {
                throw "Cannot calculate percentage: Denominator cannot be zero"
            }
            
            # Handle negative values
            if ($numerator -lt 0 -or $denominator -lt 0) {
                throw "Cannot calculate percentage: Values cannot be negative"
            }
            
            # Convert both values to bytes and store the conversions
            $percentMapper.NumeratorBytes = $this.ConvertFromBytes($numerator)
            $percentMapper.DenominatorBytes = $this.ConvertFromBytes($denominator)
            
            # Calculate percentage using original values to maintain precision
            $percentMapper.Percent = [math]::Round(($numerator / $denominator) * 100, $decimalPlaces)
            
            return $percentMapper
        }
        catch {
            Write-Error $_
            return [PSCustomObject]@{
                Error = $_.Exception.Message
            }
        }
    }
}