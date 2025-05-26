---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/iostat.1.html
schema: 2.0.0
---

# Get-IOStat

## SYNOPSIS
Retrieves system I/O and CPU statistics in JSON format for performance monitoring and analysis.

## SYNTAX

```
Get-IOStat [-CPU] [-Device] [-HumanReadable] [-Kilobytes] [-Megabytes] [-Short] [-Time] [-Extended]
 [-OmitFirst] [-OmitInactive] [-Compact] [-DecimalPlaces <String>] [-PersistentNameType <String>]
 [-Group <String>] [-GroupOnly] [-Pretty] [-Partition <String>] [[-Interval] <Int32>] [[-Count] <Int32>]
 [[-DeviceList] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
A PowerShell wrapper for the iostat utility.

Use this command to monitor CPU usage and device input/output activity over time, identify performance bottlenecks, and analyze trends in system resource utilization.
Output is always in JSON format for easy integration with other tools and scripts.

## EXAMPLES

### EXAMPLE 1
```
Get-IOStat -CPU
```

Shows CPU utilization statistics in JSON format.
Original Command: iostat -c -o JSON

### EXAMPLE 2
```
Get-IOStat -Device -HumanReadable
```

Shows device I/O stats in human-readable JSON format.
Original Command: iostat -d --human -o JSON

### EXAMPLE 3
```
Get-IOStat -Device -Interval 2 -Count 3
```

Shows device I/O stats every 2 seconds, 3 times.
Original Command: iostat -d -o JSON 2 3

## PARAMETERS

### -CPU
Display the CPU utilization report.

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

### -Device
Display the device utilization report.

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

### -HumanReadable
Display sizes in a human-readable format (e.g., 1.0k, 1.2M).

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

### -Kilobytes
Display statistics in kilobytes per second.

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

### -Megabytes
Display statistics in megabytes per second.

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

### -Short
Display a short (narrow) version of the report.

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

### -Time
Print the time for each report displayed.

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

### -Extended
Display extended statistics.

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

### -OmitFirst
Omit first report with statistics since system boot.

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

### -OmitInactive
Omit output for devices with no activity.

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

### -Compact
Display all metrics on a single line.

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

### -DecimalPlaces
Specify the number of decimal places (0-2).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PersistentNameType
Display persistent device names (ID, LABEL, PATH, UUID, etc.).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
Display statistics for a group of devices.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupOnly
Only global statistics for the group (use with -g).

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

### -Pretty
Make the Device Utilization Report easier to read by a human.

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

### -Partition
Display statistics for block devices and all their partitions (device\[,device\] or ALL).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Interval
Interval in seconds between each report.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count
Number of reports to generate.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceList
List of devices to report on (space separated).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

## OUTPUTS

## NOTES

## RELATED LINKS

[https://man7.org/linux/man-pages/man1/iostat.1.html](https://man7.org/linux/man-pages/man1/iostat.1.html)

