---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/iostat.1.html
schema: 2.0.0
---

# Get-NetworkStats

## SYNOPSIS
Calculates network statistics for a specified interface, measuring the rate of bytes and packets over a sample interval.

## SYNTAX

```
Get-NetworkStats [[-Interface] <String>] [[-SampleInterval] <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function takes two measurements of the specified interface's statistics, separated by a sample interval,
then calculates and returns the rates (bytes per second).

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Interface
The network interface to retrieve statistics for.
Default is 'eth0'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Eth0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SampleInterval
The time interval between measurements in seconds.
Default is 1 second.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
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

### [PSCustomObject]
## NOTES

## RELATED LINKS
