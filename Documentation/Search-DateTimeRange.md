---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Search-DateTimeRange

## SYNOPSIS
Filters log entry objects from the pipeline based on a specified date/time range.

## SYNTAX

```
Search-DateTimeRange [-InputObject] <PSObject> [-StartDate] <DateTime> [-EndDate] <DateTime>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This pipeline function processes objects, typically from a Read-Log* function.
It checks if an object has a Type='LogEntry' and a non-null Timestamp property.
If both conditions are met, it compares the Timestamp against the StartDate and EndDate.
Matching 'LogEntry' objects are passed through.
Other object types (like 'Error' or 'Status')
or 'LogEntry' objects with a null Timestamp are passed through without filtering.

## EXAMPLES

### EXAMPLE 1
```
Read-Log -LogFile syslog | Search-DateTimeRange -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)
```

### EXAMPLE 2
```
Read-LogAlternatives -ShowErrors | Search-DateTimeRange -StartDate '2023-10-26 00:00:00' -EndDate '2023-10-26 23:59:59'
```

## PARAMETERS

### -InputObject
{{ Fill InputObject Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -StartDate
\[datetime\] The start date and time for the filter range (inclusive).

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndDate
\[datetime\] The end date and time for the filter range (inclusive).

```yaml
Type: DateTime
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

### [PSCustomObject] Objects from a Read-Log* function or similar pipeline source.
## OUTPUTS

### [PSCustomObject] Objects that either match the date range filter (if Type='LogEntry' with a valid Timestamp)
### or other object types passed through unfiltered.
## NOTES
Relies on the input object having a 'Timestamp' property of type \[datetime\] for filtering.
If 'Timestamp' is null or missing on a 'LogEntry' object, it will not be filtered by date but will still be passed through.
Use Where-Object downstream if you need to specifically select only Type='LogEntry'.

## RELATED LINKS
