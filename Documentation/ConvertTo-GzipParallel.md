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
ConvertTo-GzipParallel [-SrcDir] <String> [-DestDir] <String> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
ConvertTo-GzipParallel compresses files from a source directory to a destination directory using parallel processing. 
It utilizes GZip compression with the smallest size level and provides progress tracking during compression. 
The function handles errors gracefully by storing them in a JSON file and can process files recursively.

The function uses parallel processing for improved performance and provides real-time progress updates with elapsed time and a ski emoji (⛷) indicator.

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-GzipParallel -SrcDir "C:\Data\Input" -DestDir "C:\Data\Output"
Compresses all files from the input directory to the output directory using parallel processing.
```

### EXAMPLE 2
```
ConvertTo-GzipParallel -SrcDir "C:\LargeDataset" -DestDir "C:\CompressedData"
Compresses files from a large dataset directory using parallel processing.
```

## PARAMETERS

### -SrcDir
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

### -DestDir
The destination directory where compressed files will be saved.
If it doesn't exist, it will be created.

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
### Accepts two string parameters: SrcDir and DestDir
## OUTPUTS

### None
### The function does not return any output but may create a CompressionErrors.json file
### in the destination directory if errors occur.
## NOTES
- Uses parallel processing for improved performance
- Creates a CompressionErrors.json file in the destination directory if any files fail to compress
- Maintains original file structure in destination directory
- Uses GZip compression with smallest size level
- Progress is tracked and displayed with elapsed time and a ski emoji (⛷) indicator
- Implements proper resource cleanup using try/catch/finally blocks
- Uses thread-safe ConcurrentDictionary for error collection

## RELATED LINKS
