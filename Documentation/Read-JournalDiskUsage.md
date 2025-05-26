---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Read-JournalDiskUsage

## SYNOPSIS
Retrieves the disk usage reported by systemd journal (plain text).

## SYNTAX

```
Read-JournalDiskUsage [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Executes 'journalctl --no-pager --disk-usage'.
Note that this command does not
support JSON output, so the raw string output is returned.
Handles errors during execution.

## EXAMPLES

### EXAMPLE 1
```
Read-JournalDiskUsage
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

### [string] The raw output string from 'journalctl --disk-usage' if successful.
### [PSCustomObject] with Type='Error' if journalctl fails.
## NOTES

## RELATED LINKS
