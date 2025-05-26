---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Read-LogAlternative

## SYNOPSIS
Reads and formats the alternatives log file, optionally including error/status details as objects.

## SYNTAX

```
Read-LogAlternative [[-Path] <String>] [-ShowErrors] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads the specified alternatives log file line by line, parsing entries into structured objects.
Handles file access and parsing errors.
Outputs detailed error objects if requested or
if terminating errors occur.
If the file is processed successfully but is empty, outputs
a Status object.

## EXAMPLES

### EXAMPLE 1
```
Read-LogAlternatives # (If file is empty)
```

### EXAMPLE 2
```
Read-LogAlternatives -ShowErrors # (If file has content and errors)
```

## PARAMETERS

### -Path
The full path to the alternatives log file.
Defaults to '/var/log/alternatives.log'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: /var/log/alternatives.log
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowErrors
If specified, detailed PSCustomObjects for any non-terminating parsing errors
encountered will be included in the output stream.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### [PSCustomObject] with properties based on 'Type':
###     - Type: 'LogAlternativeEntry' | 'Error' | 'Status'
###     - If Type='LogAlternativeEntry': Timestamp, Source, Details
###     - If Type='Error': (Same properties as defined by New-LogErrorObject)
###     - If Type='Status': Message, Path
## NOTES

## RELATED LINKS
