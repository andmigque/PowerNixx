function Protect-FileWithEncryption {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [securestring]$FilePassword
    )

    # Check if the file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "The file '$FilePath' does not exist."
        return
    }

    # Generate a random salt
    $salt = New-Object byte[] 16
    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($salt)

    # Derive a key from the password and salt
    $key = New-Object byte[] 32
    $pbkdf2 = New-Object Security.Cryptography.Rfc2898DeriveBytes($FilePassword, $salt, 100000)
    $key = $pbkdf2.GetBytes(32)

    # Create an AES object
    $aes = [Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = (New-Object byte[] 16)
    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($aes.IV)

    # Encrypt the file
    $encryptor = $aes.CreateEncryptor()
    $fileStream = [System.IO.File]::Open($FilePath, 'Open', 'Read')
    $encryptedStream = [System.IO.File]::Open("$FilePath.enc", 'Create', 'Write')
    
    # Write the salt and IV to the encrypted file
    $encryptedStream.Write($salt, 0, $salt.Length)
    $encryptedStream.Write($aes.IV, 0, $aes.IV.Length)

    # Create a CryptoStream to encrypt the data
    $cryptoStream = New-Object Security.Cryptography.CryptoStream($encryptedStream, $encryptor, 'Write')

    # Read from the original file and write to the encrypted stream
    try {
        $buffer = New-Object byte[] 4096
        while (($bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $cryptoStream.Write($buffer, 0, $bytesRead)
        }
        Write-Host "File '$FilePath' has been encrypted successfully."
    }
    finally {
        # Clean up streams
        $cryptoStream.Close()
        $fileStream.Close()
        $encryptedStream.Close()
    }   
}

function Unprotect-EncryptedFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$EncryptedFilePath,

        [Parameter(Mandatory = $true)]
        [securestring]$FilePassword,

        [Parameter(Mandatory = $true)]
        [string]$OutputFilePath
    )

    # Check if the encrypted file exists
    if (-Not (Test-Path -Path $EncryptedFilePath)) {
        Write-Error "The encrypted file '$EncryptedFilePath' does not exist."
        return
    }

    # Open the encrypted file for reading
    $encryptedStream = [System.IO.File]::Open($EncryptedFilePath, 'Open', 'Read')

    try {
        # Read the salt from the encrypted file
        $salt = New-Object byte[] 16
        $encryptedStream.Read($salt, 0, $salt.Length) | Out-Null

        # Read the IV from the encrypted file
        $iv = New-Object byte[] 16
        $encryptedStream.Read($iv, 0, $iv.Length) | Out-Null

        # Derive the key from the password and salt
        $pbkdf2 = New-Object Security.Cryptography.Rfc2898DeriveBytes($FilePassword, $salt, 100000)
        $key = $pbkdf2.GetBytes(32)

        # Create an AES object
        $aes = [Security.Cryptography.Aes]::Create()
        $aes.Key = $key
        $aes.IV = $iv

        # Create a decryptor
        $decryptor = $aes.CreateDecryptor()

        # Create a CryptoStream to decrypt the data
        $cryptoStream = New-Object Security.Cryptography.CryptoStream($encryptedStream, $decryptor, 'Read')

        # Open the output file for writing
        $outputStream = [System.IO.File]::Open($OutputFilePath, 'Create', 'Write')

        try {
            # Read from the CryptoStream and write to the output file
            $buffer = New-Object byte[] 4096
            while (($bytesRead = $cryptoStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $outputStream.Write($buffer, 0, $bytesRead)
            }
            Write-Host "File '$EncryptedFilePath' has been decrypted successfully to '$OutputFilePath'."
        }
        finally {
            # Clean up streams
            $outputStream.Close()
            $cryptoStream.Close()
        }
    }
    catch {
        Write-Error "An error occurred while decrypting the file: $_"
    }
    finally {
        # Close the encrypted stream
        $encryptedStream.Close()
    }
}