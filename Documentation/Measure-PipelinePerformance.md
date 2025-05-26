---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Measure-PipelinePerformance

## SYNOPSIS
Measures the execution time and item count for a PowerShell pipeline.

## SYNTAX

```
Measure-PipelinePerformance [-InputObject] <PSObject> [[-Description] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Place this function at the END of a pipeline.
It measures the total time elapsed from the
moment the first object enters it until the pipeline completes.
It counts the number of
'LogEntry' type objects processed and the total number of objects that pass through it.

In the 'end' block, after passing all received objects through, it outputs a final
'PipelinePerformanceSummary' object containing the timing and count statistics.

## EXAMPLES

### EXAMPLE 1
```
Read-Log -LogFile syslog -Tail 5000 | Group-LogByNegative | Measure-PipelinePerformance -Description "Syslog Negative Entry Processing"
```

### EXAMPLE 2
```
Get-VarLogs -ShowErrors | Measure-PipelinePerformance
```

## PARAMETERS

### -InputObject
\[PSCustomObject\] An object from the preceding pipeline stage.

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

### -Description
\[string\] An optional description to include in the summary output, helping to identify
what process was being measured.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### [PSCustomObject] A stream of objects from any PowerShell pipeline.
## OUTPUTS

### [PSCustomObject] Passes through ALL objects received from the pipeline.
### [PSCustomObject] with Type='PipelinePerformanceSummary' emitted ONCE at the end, containing:
###     - Description (string, optional)
###     - ElapsedTime (TimeSpan)
###     - TotalSeconds (double)
###     - LogEntryCount (int)
###     - TotalObjectCount (int)
###     - LogEntriesPerSecond (double)
###     - Type (string, 'PipelinePerformanceSummary')
## NOTES
This function measures the combined time of ALL preceding stages in the pipeline PLUS its own overhead.
It should be the *last* command in the pipeline segment you want to measure.
The 'LogEntriesPerSecond' calculation avoids division by zero if the elapsed time is negligible.
It relies on input objects having a 'Type' property to specifically count 'LogEntry' items.

## RELATED LINKS
