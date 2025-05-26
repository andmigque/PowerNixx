---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/systemctl.1.html
https://www.freedesktop.org/software/systemd/man/systemctl.html
schema: 2.0.0
---

# Get-System

## SYNOPSIS
Get-System -ListUnits | Get-System -Status | Get-System -Show

## SYNTAX

```
Get-System [-ListUnits] [-ListAutoMounts] [-ListSockets] [-ListTimers] [-Show] [-Status] [-All] [-Help] [-Now]
 [-Failed] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
A PowerShell wrapper for systemctl.
Use to retrieve systemd unit, socket, timer, and automount information in JSON format.
Supports listing, status, and property queries for systemd-managed resources.

## EXAMPLES

### EXAMPLE 1
```
Get-System -ListUnits
```

Lists all active systemd units in JSON format.
Original Command: systemctl list-units --no-pager --output=json

### EXAMPLE 2
```
Get-System -Status
```

Shows the overall status of the system or a specific unit.
Original Command: systemctl status --no-pager --output=json

### EXAMPLE 3
```
Get-System -Show
```

Displays properties of the system or a specific unit.
Original Command: systemctl show --no-pager --output=json

## PARAMETERS

### -ListUnits
List active systemctl units.

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

### -ListAutoMounts
List automount units currently in memory.

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

### -ListSockets
List socket units currently in memory.

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

### -ListTimers
List timer units currently in memory.

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

### -Show
Show properties of the system or a specific unit.

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

### -Status
Show the overall status or the status of a specific unit.

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

### -All
Show all available output.

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

### -Help
Show help for systemctl.

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

### -Now
Do the action now, don't wait for reload.

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

### -Failed
Show any failed units.

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

## NOTES

## RELATED LINKS

[https://man7.org/linux/man-pages/man1/systemctl.1.html
https://www.freedesktop.org/software/systemd/man/systemctl.html](https://man7.org/linux/man-pages/man1/systemctl.1.html
https://www.freedesktop.org/software/systemd/man/systemctl.html)

[https://man7.org/linux/man-pages/man1/systemctl.1.html
https://www.freedesktop.org/software/systemd/man/systemctl.html]()

