function Start-Gemma3Cli {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModelPath,

        [Parameter(Mandatory=$true)]
        [string]$ProjectorPath,

        [int]$Threads = 12,
        [int]$ThreadsBatch = 8,
        [int]$ContextSize = 4096,
        [string]$Prompt,
        [int]$GpuLayers = 36,
        [ValidateSet("none", "layer", "row")]
        [string]$SplitMode = "layer",
        [string]$TensorSplit
    )

    try {
        $command = "llama-gemma3-cli -m $ModelPath"
        $command += " --mmproj $ProjectorPath"
        if ($Threads) {
            $command += " --threads $Threads"
        }
        if ($ThreadsBatch) {
            $command += " --threads-batch $ThreadsBatch"
        }
        if ($ContextSize) {
            $command += " -c $ContextSize"
        }
        if ($Prompt) {
            $command += " -p $Prompt"
        }
        if ($GpuLayers) {
            $command += " -ngl $GpuLayers"
        }
        if ($SplitMode) {
            $command += " -sm $SplitMode"
        }
        if ($TensorSplit) {
            $command += " -ts $TensorSplit"
        }
        $command += " --flash-attn"
        $command += " --mlock"

        Invoke-Expression -Command $command
    } catch {
        Write-Error "Failed to execute llama-gemma3-cli command. Error: $_.Exception.Message"
        Write-Error "$_.Exception.StackTrace"
    }
}

function Start-Llama3Cli {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModelPath,

        [string]$ChatTemplate = "gemma",
        [string]$SysMessage,
        [string]$PromptCache,
        [string]$LogFile,
        [string]$TensorSplit = "3,1",
        [int]$GpuLayers = 2048,
        [int]$ContextSize = 8192,
        [int]$Threads = 4,
        [int]$ThreadsBatch = 4,
        [float]$Temperature = 0.8
    )

    try {
        $command = "llama-cli -m $ModelPath"
        $command += " --chat-template $ChatTemplate"
        if ($SysMessage) {
            $command += " -sys `"$SysMessage`""
        }
        $command += " --multiline-input --conversation"
        if ($PromptCache) {
            $command += " --prompt-cache $PromptCache --prompt-cache-all"
        }
        if ($LogFile) {
            $command += " --log-file $LogFile"
        }
        if ($TensorSplit) {
            $command += " --tensor-split '$TensorSplit'"
        }
        if ($GpuLayers) {
            $command += " --gpu-layers $GpuLayers"
        }
        $command += " --keep -1"
        if ($ContextSize) {
            $command += " -c $ContextSize"
        }
        if ($Threads) {
            $command += " --threads $Threads"
        }
        if ($ThreadsBatch) {
            $command += " --threads-batch $ThreadsBatch"
        }
        if ($Temperature) {
            $command += " --temp $Temperature"
        }
        $command += " --mlock --flash-attn"

        Invoke-Expression -Command $command
    } catch {
        Write-Error "Failed to execute llama-cli command. Error: $_.Exception.Message"
        Write-Error "$_.Exception.StackTrace"
    }
}
