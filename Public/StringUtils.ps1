

function Split-LinesBySpace {
    Param(
        [String]$UnixLines
    )
    return $UnixLines.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
}