function ConvertTo-StringArray{
    param([string]$text)
    $lines = @()
    foreach($line in $text.Split([Environment]::RemoveEmptyEntries)) {
        $lines.Add($line)
    }
}

# Removes spaces from a given string and returns the resulting array of words.
function Remove-Spaces {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Line
    )
    try {
        return $Line.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
    }
    catch {
        Write-Error "Failed to remove spaces from the input string. Error: $_"
    }
}
