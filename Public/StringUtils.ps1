

function Split-LinesBySpace {
    Param(
        [String]$UnixLines
    )
    return $UnixLines.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
}

function Split-LineByNewLine {
    [CmdletBinding()]
    param([string]$Lines)
    try {
        return $Lines.Split("`n", [System.StringSplitOptions]::RemoveEmptyEntries)
    }
    catch {
        Write-Error $_
        return @{ 
            Error = $_
        }
    }
}