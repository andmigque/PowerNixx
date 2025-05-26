---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Protect-FileWithEncryption

## SYNOPSIS
Encrypts a file using AES encryption with a password-derived key.

## SYNTAX

```
Protect-FileWithEncryption [-FilePath] <String> [-FilePassword] <SecureString>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function encrypts a file using AES encryption.
It generates a random salt 
and IV (Initialization Vector), derives a key from the provided password and salt 
using PBKDF2 (Password-Based Key Derivation Function 2), and writes the encrypted 
Set-StrictMode -Version 3.0
data to a new file with the \`.enc\` extension.
The salt and IV are stored at the 
beginning of the encrypted file for decryption purposes.

## EXAMPLES

### EXAMPLE 1
```
Protect-FileWithEncryption -FilePath ./AboutOperators.txt -FilePassword (Read-Host -Prompt "Enter encryption password" -AsSecureString)
```

## PARAMETERS

### -FilePath
The path to the file to be encrypted.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePassword
A secure string representing the password used to derive the encryption key.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None. Writes the encrypted file to the same directory as the original file with 
### the `.enc` extension.
## NOTES
- The password must be securely stored or remembered, as it is required for decryption.
- The function uses AES encryption with a 256-bit key.

## RELATED LINKS
