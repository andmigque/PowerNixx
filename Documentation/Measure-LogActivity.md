---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Measure-LogActivity

## SYNOPSIS
Analyzes a stream of log entry objects from the pipeline to summarize activity per server.

## SYNTAX

```
Measure-LogActivity [-InputObject] <PSObject> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This pipeline function processes objects, expecting standard log objects with 'Type', 'ServerName',
and 'Timestamp' properties (where Type='LogEntry').
It filters for successful 'LogEntry' objects
that have a valid \[datetime\] Timestamp.
It calculates the overall earliest and latest timestamps
from all valid entries processed across the entire pipeline input.

In the 'end' block, it groups the valid entries by ServerName and outputs a summary object
for each server, including the log count and the overall time range observed across all servers.
Any non-'LogEntry' objects (like 'Error' or 'Status') received from upstream are passed through.

## EXAMPLES

### EXAMPLE 1
```
Read-Log -LogFile syslog -Tail 1000 | Measure-LogActivity | Sort-Object -Property LogCount -Descending
```

### EXAMPLE 2
```
Read-LogAlternatives -ShowErrors | Measure-LogActivity
```

## PARAMETERS

### -InputObject
\[PSCustomObject\] An object from the pipeline, expected to conform to the standard log object structure
(having Type, ServerName, Timestamp properties if it's a log entry).

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

### [PSCustomObject] A stream of objects, typically from a Read-Log* function or filtered pipeline.
## OUTPUTS

### [PSCustomObject] with properties based on 'Type':
###     - Type: 'LogActivitySummary' | 'Error' | 'Status' | (Other types passed through)
###     - If Type='LogActivitySummary': ServerName (string), LogCount (int), GlobalOldestTimestamp (DateTime), GlobalNewestTimestamp (DateTime)
###     - If Type='Error': (Properties from New-LogErrorObject)
###     - If Type='Status': (Properties defined by the upstream Status object)
###     - Other object types passed through retain their original structure.
## NOTES
Relies on input 'LogEntry' objects having a 'ServerName' property for grouping and a valid \[datetime\] 'Timestamp' property for range calculation.
Objects without these properties or with different 'Type' values will be handled gracefully (passed through or ignored for summary stats).
The Timestamps reported in the summary are the global minimum and maximum across ALL valid log entries processed from the input stream.

## RELATED LINKS
