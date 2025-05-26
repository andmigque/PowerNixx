using namespace System.Security.Cryptography
using namespace System.IO
Set-StrictMode -Version 3.0

function Protect-FileWithEncryption {
<#

.SYNOPSIS
Encrypts a file using AES encryption with a password-derived key.

.DESCRIPTION
This function encrypts a file using AES encryption. It generates a random salt 
and IV (Initialization Vector), derives a key from the provided password and salt 
using PBKDF2 (Password-Based Key Derivation Function 2), and writes the encrypted 
Set-StrictMode -Version 3.0
data to a new file with the `.enc` extension. The salt and IV are stored at the 
beginning of the encrypted file for decryption purposes.

.PARAMETER FilePath
The path to the file to be encrypted.

.PARAMETER FilePassword
A secure string representing the password used to derive the encryption key.

.OUTPUTS
None. Writes the encrypted file to the same directory as the original file with 
the `.enc` extension.

.EXAMPLE
Protect-FileWithEncryption -FilePath ./AboutOperators.txt -FilePassword (Read-Host -Prompt "Enter encryption password" -AsSecureString)               

.NOTES
- The password must be securely stored or remembered, as it is required for decryption.
- The function uses AES encryption with a 256-bit key.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [securestring]$FilePassword
    )

    # Check if the file exists


    try {
        if (-Not (Test-Path -Path $FilePath)) {
            throw "$FilePath does not exist."
        }
        # Generate a random salt
        $salt = [byte[]]::new(16)
        [RNGCryptoServiceProvider]::Create().GetBytes($salt)

        # Derive a key from the password and salt
        $pbkdf2 = [Rfc2898DeriveBytes]::new($FilePassword, $salt, 100000)
        $key = $pbkdf2.GetBytes(32)

        # Create an AES object
        $aes = [Aes]::Create()
        $aes.Key = $key
        [RNGCryptoServiceProvider]::Create().GetBytes($aes.IV)

        # Encrypt the file
        $encryptor = $aes.CreateEncryptor()
        $fileStream = [File]::Open($FilePath, 'Open', 'Read')
        $encryptedFilePath = "$FilePath.enc"
        $encryptedStream = [File]::Open($encryptedFilePath, 'Create', 'Write')

        # Write the salt and IV to the encrypted file
        $encryptedStream.Write($salt, 0, $salt.Length)
        $encryptedStream.Write($aes.IV, 0, $aes.IV.Length)

        # Create a CryptoStream to encrypt the data
        $cryptoStream = [CryptoStream]::new($encryptedStream, $encryptor, [CryptoStreamMode]::Write)

        try {
            # Encrypt the file data in chunks
            $buffer = [byte[]]::new(4096)
            while (($bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $cryptoStream.Write($buffer, 0, $bytesRead)
            }

            # Return a success object with relevant details
            return New-EncryptionResultObject -Status 'Success' `
                -OriginalFile $FilePath `
                -EncryptedFile $encryptedFilePath `
                -OriginalFileSizeKB (($fileStream.Length / 1KB) -as [int]) `
                -EncryptedFileSizeKB (([FileInfo]::new($encryptedFilePath).Length / 1KB) -as [int]) `
                -Salt ([Convert]::ToBase64String($salt)) `
                -IV ([Convert]::ToBase64String($aes.IV))
        }
        finally {
            # Clean up streams
            $cryptoStream.Close()
            $fileStream.Close()
            $encryptedStream.Close()
        }
    }
    catch {
        # Handle errors and return a generic error object
        return New-PsNxError -Data $_
    }
}

function Unprotect-EncryptedFile {
<#
.SYNOPSIS
Decrypts a file encrypted with Protect-FileWithEncryption.

.DESCRIPTION
This function decrypts a file that was encrypted using the `Protect-FileWithEncryption`
function. It reads the salt and IV from the encrypted file, derives the decryption 
key using the provided password and salt, and writes the decrypted data to a new file.

.PARAMETER EncryptedFilePath
The path to the encrypted file to be decrypted.

.PARAMETER FilePassword
A secure string representing the password used to derive the decryption key.

.PARAMETER OutputFilePath
The path where the decrypted file will be written.

.OUTPUTS
None. Writes the decrypted file to the specified output path.

.EXAMPLE
Unprotect-EncryptedFile -EncryptedFilePath AboutOperators.txt.enc -FilePassword (Read-Host -Prompt "Enter Password" -AsSecureString) -OutputFilePath AboutOperatorsDecrypted.txt

.NOTES
- The password must match the one used during encryption.
- If the password is incorrect or the file is corrupted, decryption will fail.
#>
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
        return New-PsNxError -ErrorMessage "The encrypted file '$EncryptedFilePath' does not exist."
    }

    try {
        # Open the encrypted file for reading
        $encryptedStream = [File]::Open($EncryptedFilePath, 'Open', 'Read')

        try {
            # Read the salt and IV from the encrypted file
            $salt = [byte[]]::new(16)
            $encryptedStream.Read($salt, 0, $salt.Length) | Out-Null

            $iv = [byte[]]::new(16)
            $encryptedStream.Read($iv, 0, $iv.Length) | Out-Null

            # Derive the key from the password and salt
            $pbkdf2 = [Rfc2898DeriveBytes]::new($FilePassword, $salt, 100000)
            $key = $pbkdf2.GetBytes(32)

            # Create an AES object
            $aes = [Aes]::Create()
            $aes.Key = $key
            $aes.IV = $iv

            # Create a decryptor
            $decryptor = $aes.CreateDecryptor()

            # Create a CryptoStream to decrypt the data
            $cryptoStream = [CryptoStream]::new($encryptedStream, $decryptor, [CryptoStreamMode]::Read)

            # Open the output file for writing
            $outputStream = [File]::Open($OutputFilePath, 'Create', 'Write')

            try {
                # Decrypt the file data in chunks
                $buffer = [byte[]]::new(4096)
                while (($bytesRead = $cryptoStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $outputStream.Write($buffer, 0, $bytesRead)
                }

                # Return a success object with relevant details
                return New-EncryptionResultObject -Status 'Success' `
                    -OriginalFile $EncryptedFilePath `
                    -EncryptedFile $OutputFilePath `
                    -Salt ([Convert]::ToBase64String($salt)) `
                    -IV ([Convert]::ToBase64String($iv))
            }
            finally {
                # Clean up streams
                $outputStream.Close()
                $cryptoStream.Close()
            }
        }
        finally {
            $encryptedStream.Close()
        }
    }
    catch {
        # Handle errors and return a generic error object
        return New-PsNxError -ErrorMessage 'An error occurred during decryption.' `
            -Details $_
    }
}