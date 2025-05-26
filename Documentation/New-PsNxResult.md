---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# New-PsNxResult

## SYNOPSIS
Creates a standardized PSCustomObject representing a generic result.

## SYNTAX

```
New-PsNxResult [[-Status] <String>] [[-Data] <Object>] [[-Error] <Object>] [[-Generator] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Takes a status, optional data, and optional error information, and formats them into a consistent
PSCustomObject for output streams. 
Can represent success, info, or error conditions.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Status
The status of the operation ('Success', 'Info', or 'Error').

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Success
Accept pipeline input: False
Accept wildcard characters: False
```

### -Data
The data or result of the operation (optional). 
Can be any PowerShell object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Error
An error object (e.g., from a catch block) or a string error message. 
If provided, Status will be automatically set to 'Error'.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Generator
The Generator of the result (e.g., cmdlet name, script name).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Unknown
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

### [PSCustomObject] Detailed result information with Resultant='PsNxResult'.
## NOTES

## RELATED LINKS
