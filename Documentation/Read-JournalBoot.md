---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Read-JournalBoot

## SYNOPSIS
Retrieves systemd journal boot list information as PowerShell objects.

## SYNTAX

```
Read-JournalBoot [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Executes 'journalctl --no-pager --list-boots --output=json' and converts the
JSON output into PowerShell objects.
Handles errors during execution or JSON conversion.

## EXAMPLES

### EXAMPLE 1
```
Read-JournalBoot | Sort-Object -Property bootTime | Select-Object -Last 1
```

## PARAMETERS

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

### [PSCustomObject[]] An array of objects representing boot entries if successful.
### [PSCustomObject] with Type='Error' if journalctl fails or JSON conversion fails.
## NOTES

## RELATED LINKS
