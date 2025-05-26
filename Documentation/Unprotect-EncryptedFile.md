---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Unprotect-EncryptedFile

## SYNOPSIS
Decrypts a file encrypted with Protect-FileWithEncryption.

## SYNTAX

```
Unprotect-EncryptedFile [-EncryptedFilePath] <String> [-FilePassword] <SecureString> [-OutputFilePath] <String>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function decrypts a file that was encrypted using the \`Protect-FileWithEncryption\`
function.
It reads the salt and IV from the encrypted file, derives the decryption 
key using the provided password and salt, and writes the decrypted data to a new file.

## EXAMPLES

### EXAMPLE 1
```
Unprotect-EncryptedFile -EncryptedFilePath AboutOperators.txt.enc -FilePassword (Read-Host -Prompt "Enter Password" -AsSecureString) -OutputFilePath AboutOperatorsDecrypted.txt
```

## PARAMETERS

### -EncryptedFilePath
The path to the encrypted file to be decrypted.

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
A secure string representing the password used to derive the decryption key.

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

### -OutputFilePath
The path where the decrypted file will be written.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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

### None. Writes the decrypted file to the specified output path.
## NOTES
- The password must match the one used during encryption.
- If the password is incorrect or the file is corrupted, decryption will fail.

## RELATED LINKS
