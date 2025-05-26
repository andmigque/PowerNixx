---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Read-Log

## SYNOPSIS
Reads and formats specified system log files using generic patterns.

## SYNTAX

```
Read-Log [-LogFile] <String> [[-Tail] <Int32>] [[-LargeFileThresholdMB] <Int32>] [-ShowErrors]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads a specified log file (cron, user, auth, syslog) line by line using generic regex patterns.
Outputs structured objects containing the raw captured fields.
Attempts to parse the timestamp
string into a DateTime object.
Includes error handling and status reporting.

## EXAMPLES

### EXAMPLE 1
```
Read-Log -LogFile syslog -Tail 50 | Where-Object { $_.Type -eq 'LogEntry' -and $_.Timestamp -ne $null }
```

### EXAMPLE 2
```
Read-Log -LogFile cron -ShowErrors | ConvertTo-Json
```

## PARAMETERS

### -LogFile
The type of log file to read.
Possible values are 'cron', 'user', 'auth', 'syslog'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tail
The number of lines from the end of the file to read.
Default is 100.
Set to $null or 0 to read the whole file.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -LargeFileThresholdMB
Warns if the log file exceeds this size in MB.
Default is 500.
Set to 0 to disable warning.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 500
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
###     - Type: 'LogEntry' | 'Error' | 'Status'
###     - If Type='LogEntry': LogDate (string), ServerName (string), ProcessWithPID (string), Message (string), Timestamp (DateTime or $null)
###     - If Type='Error': (Same properties as defined by New-LogErrorObject)
###     - If Type='Status': Message, Path
## NOTES
Uses generic regex patterns.
Timestamp parsing is best-effort based on common PowerShell convertible formats (like ISO 8601).
If parsing fails, the 'Timestamp' property will be null, but the raw 'LogDate' string is always preserved.

## RELATED LINKS
