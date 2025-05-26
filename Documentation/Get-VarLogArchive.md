---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/systemctl.1.html
https://www.freedesktop.org/software/systemd/man/systemctl.html
schema: 2.0.0
---

# Get-VarLogArchive

## SYNOPSIS
Lists all archived log files in /var/log, optionally including error details as objects.

## SYNTAX

```
Get-VarLogArchive [-ShowErrors] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves archived log files (*.gz, *.xz, *.bz2, *.zip) in /var/log and subdirectories.
Outputs PSCustomObjects for each file found.
Uses -ErrorAction SilentlyContinue and
-ErrorVariable to capture access errors.
If -ShowErrors is specified, PSCustomObjects
representing non-terminating errors are also output to the success stream.
Terminating
errors also result in an Error-type PSCustomObject being output.
All output objects have
a 'Type' property ('LogArchive' or 'Error') for filtering.

## EXAMPLES

### EXAMPLE 1
```
Get-VarLogArchives | Where-Object { $_.Type -eq 'LogArchive' }
```

### EXAMPLE 2
```
Get-VarLogArchives -ShowErrors
```

## PARAMETERS

### -ShowErrors
If specified, detailed PSCustomObjects for any non-terminating errors encountered
during the scan will be included in the output stream.

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
###     - Type: 'LogArchive' | 'Error'
###     - If Type='LogArchive': Name, FullName, SizeKB
###     - If Type='Error': (Same properties as defined by New-LogErrorObject)
## NOTES

## RELATED LINKS
