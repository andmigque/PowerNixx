---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://github.com/andmigque/powernixx
schema: 2.0.0
---

# ConvertTo-GzipParallel

## SYNOPSIS
Parallel compression of files using .NET native GZip streams

## SYNTAX

```
ConvertTo-GzipParallel [-SourceDirectory] <String> [-DestinationDirectory] <String>
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
ConvertTo-GzipParallel compresses files from a source directory to a destination directory using parallel processing. 
It utilizes GZip compression with the smallest size level and provides progress tracking during compression. 
The function handles errors gracefully by storing them in a JSON file and can process files recursively.

The function uses parallel processing for improved performance.
It provides real-time progress updates with elapsed time and a ski emoji (⛷) indicator.

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-GzipParallel -SourceDirectory "C:\Data\Input" -DestDir "C:\Data\Output"
```

### EXAMPLE 2
```
ConvertTo-GzipParallel -SourceDirectory "C:\LargeDataset" -DestDir "C:\CompressedData"
```

## PARAMETERS

### -SourceDirectory
The source directory containing files to compress.
Must be an existing directory path.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DestinationDirectory
{{ Fill DestinationDirectory Description }}

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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

### System.String
### Accepts two string parameters: SourceDirectory and DestDir
## OUTPUTS

### None
### The function does not return any output but may create a CompressionErrors.json file
### in the destination directory if errors occur.
## NOTES
- Uses parallel processing for improved performance
- Creates a CompressionErrors.json file in the destination directory if any files fail to compress
- Maintains original directory structure in destination directory
- Uses GZip compression with smallest size level
- Progress is tracked and displayed with elapsed time and a ski emoji (⛷) indicator
- Implements proper resource cleanup using try/catch/finally blocks
- Uses thread-safe ConcurrentDictionary for error collection

## RELATED LINKS

[https://github.com/PowerShell/platyPS](https://github.com/PowerShell/platyPS)

[https://github.com/andmigque/powernixx](https://github.com/andmigque/powernixx)

[https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.gzipstream?view=net-9.0](https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.gzipstream?view=net-9.0)

