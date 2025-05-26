---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Show-LogArchivesLarge

## SYNOPSIS
Provides a simplified view of show log archives with a built in size of 50MB.

## SYNTAX

```
Show-LogArchivesLarge [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
A convenience function that calls Get-LogArchives pipelined into where-object then filtered by size with specific parameters
and formats the output, typically using Format-Table.

## EXAMPLES

### EXAMPLE 1
```
Show-LogArchivesLarge
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

## NOTES

## RELATED LINKS
