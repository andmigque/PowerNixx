---
external help file: PowerNixx-help.xml
Module Name: PowerNixx
online version: https://man7.org/linux/man-pages/man1/tar.1.html
https://www.gnu.org/software/tar/manual/tar.html
schema: 2.0.0
---

# Start-OllamaModel

## SYNOPSIS
Starts an Ollama model shell using a specified model name.

## SYNTAX

```
Start-OllamaModel [-ModelName] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function starts an Ollama model shell by executing the 'ollama run $ModelName' command.
It includes error handling to manage exceptions that may occur during execution.

## EXAMPLES

### EXAMPLE 1
```
Start-OllamaModelShell -ModelName 'phi4power'
```

## PARAMETERS

### -ModelName
The name of the Ollama model to start.
Must be provided as input.

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
This script requires PowerShell Core or higher due to potential cross-platform requirements.

## RELATED LINKS
