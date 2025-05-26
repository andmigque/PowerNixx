---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/iostat.1.html
schema: 2.0.0
---

# Get-Memory

## SYNOPSIS
Retrieves system memory statistics using the proc filesystem and jc parser.

## SYNTAX

```
Get-Memory [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads memory information from /proc/meminfo, converts it to a structured format
using the jc parser, and returns memory statistics with both byte values and
percentages.
Handles errors during execution and conversion.

## EXAMPLES

### EXAMPLE 1
```
Get-Memory
```

### EXAMPLE 2
```
Get-Memory | Format-Memory
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

### [PSCustomObject] with the following properties:
### - Total: Total system memory with byte value and unit
### - Used: Used memory with byte value and unit
### - Available: Available memory with byte value and unit
### - Buffers: Memory used for buffers with byte value and unit
### - Cached: Cached memory with byte value and unit
### - UsedPercent: Percentage of memory used
### - AvailablePercent: Percentage of memory available
### - BuffersPercent: Percentage of memory used for buffers
### - CachedPercent: Percentage of memory used for cache
### In case of error, returns:
### [PSCustomObject] with Error property containing the error message
## NOTES

## RELATED LINKS
