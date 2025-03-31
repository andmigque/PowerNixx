<#
Show information for an Ollama model

Usage:

Show-OllamaModel -ModelName "llama3.2" -License
Show-OllamaModel -ModelName "llama3.2" -ModelFile
Show-OllamaModel -ModelName "llama3.2" -Parameters

Flags:
-License: Show license of the model
-ModelFile: Show Modelfile of the model
-Parameters: Show parameters of the model
-SystemMessage: Show system message of the model
-Template: Show template of the model
#>

function Show-OllamaModel {

    [CmdletBinding()]
    param(
        [string]$ModelName,
        [string]$License,
        [string]$ModelFile,
        [string]$Parameters,
        [string]$SystemMessage,
        [string]$Template
    )

    try {
        # Execute the Ollama show command with the specified flags
        (ollama show $ModelName --license $License --modelfile $ModelFile --parameters $Parameters --system $SystemMessage --template $Template)
    } catch {
        Write-Error $_.Exception.Message
    }
}
