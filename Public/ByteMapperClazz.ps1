# Script-scoped constants
$script:BYTE_UNITS = @{
    KB = [double]1024
    MB = [double](1024 * 1024)
    GB = [double](1024 * 1024 * 1024)
}

# Script-scoped byte mapper template
$script:BYTE_MAPPER_TEMPLATE = @{
    HumanBytes    = 0
    Unit          = 'B'
    OriginalBytes = 0
}

$script:PERCENT_MAPPER_TEMPPLATE = @{
    NumeratorBytes   = $script:BYTE_MAPPER_TEMPLATE.clone()
    DenominatorBytes = $script:BYTE_MAPPER_TEMPLATE.clone()
    Percent          = 0.0
}

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
}