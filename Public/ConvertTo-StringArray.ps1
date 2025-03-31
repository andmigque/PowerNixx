function ConvertTo-StringArray{
    param([string]$text)
    $lines = @()
    foreach($line in $text.Split([Environment]::RemoveEmptyEntries)) {
        $lines.Add($line)
    }
}
