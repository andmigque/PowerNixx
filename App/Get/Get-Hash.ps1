function Get-Hash {
    param (
        [Parameter(Mandatory)]
        [string]$Path,
        [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
        [string]$Algorithm = 'MD5'
    )

    try {
        $fileHash = Get-FileHash -Path $Path -Algorithm $Algorithm
        return $fileHash.HashString
    } catch {
        Write-Error $_
    }
}