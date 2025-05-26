---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://github.com/andmigque/powernixx
schema: 2.0.0
---

# Invoke-Tar

## SYNOPSIS
tar wrapper for creating, extracting, and listing tar archives.

## SYNTAX

### list
```
Invoke-Tar [-Show] [[-Archive] <String>] [-List] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### extract
```
Invoke-Tar [-Show] [[-Archive] <String>] [-Extract] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Create
```
Invoke-Tar [-Show] [[-Archive] <String>] [-New] [-Files <String[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
A PowerShell wrapper for the tar utility.
Use to create, extract, or list the contents of tar archives.
Supports common tar operations with clear PowerShell semantics.

## EXAMPLES

### EXAMPLE 1
```
Invoke-Tar -List -Archive 'archive.tar'
```

Lists the contents of 'archive.tar'.
Original Command: tar -tf archive.tar

### EXAMPLE 2
```
Invoke-Tar -Extract -Archive 'archive.tar'
```

Extracts all files from 'archive.tar' into the current directory.
Original Command: tar -xf archive.tar

### EXAMPLE 3
```
Invoke-Tar -New -Archive 'archive.tar' -Files @('file1.txt','file2.txt')
```

Creates a new archive 'archive.tar' containing file1.txt and file2.txt.
Original Command: tar -cf archive.tar file1.txt file2.txt

## PARAMETERS

### -Show
Show the progress and file names as tar operates (verbose mode).

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Archive
The archive file to create, extract, or list.
Required for most operations.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -List
List the contents of an archive without extracting.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: list
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Extract
Extract files from the specified archive.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: extract
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -New
Create a new archive.
Use with -Archive and -Files.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Create
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Files
The files to include in the new archive.
Accepts an array of file paths.

```yaml
Type: System.String[]
Parameter Sets: Create
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: System.Management.Automation.ActionPreference
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

[https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html](https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html)

[https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html]()

