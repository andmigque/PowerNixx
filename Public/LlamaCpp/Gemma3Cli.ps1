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
            $command += " -threads-batch $ThreadsBatch"
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

