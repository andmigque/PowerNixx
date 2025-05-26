---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Read-JournalJson

## SYNOPSIS
Retrieves systemd journal entries and converts the JSON output into PowerShell objects.

## SYNTAX

```
Read-JournalJson [[-JournalctlPath] <String>] [[-Priority] <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Executes 'journalctl --output=json' with common options (--no-pager, -a, -r, -m)
and pipes the entire JSON output stream directly to ConvertFrom-Json.
Handles errors during the execution of journalctl or the final JSON conversion.

## EXAMPLES

### EXAMPLE 1
```
Get-JournalJson | Where-Object { $_.PRIORITY -eq '3' }
```

## PARAMETERS

### -JournalctlPath
The path to the journalctl executable.
Defaults to '/usr/bin/journalctl'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: /usr/bin/journalctl
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority
{{ Fill Priority Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 3
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

### [PSCustomObject[]] An array of objects representing journal entries if successful.
### [PSCustomObject] with Type='Error' if journalctl fails or the final JSON conversion fails.
## NOTES

## RELATED LINKS
