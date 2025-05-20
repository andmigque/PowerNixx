# Module created by Microsoft.PowerShell.Crescendo
# Version: 1.1.0
# Schema: https://aka.ms/PowerShell/Crescendo/Schemas/2021-11
# Generated at: 05/20/2025 01:21:17
class PowerShellCustomFunctionAttribute : System.Attribute {
    [bool]$RequiresElevation
    [string]$Source
    PowerShellCustomFunctionAttribute() { $this.RequiresElevation = $false; $this.Source = "Microsoft.PowerShell.Crescendo" }
    PowerShellCustomFunctionAttribute([bool]$rElevation) {
        $this.RequiresElevation = $rElevation
        $this.Source = "Microsoft.PowerShell.Crescendo"
    }
}

# Returns available errors
# Assumes that we are being called from within a script cmdlet when EmitAsError is used.
function Pop-CrescendoNativeError {
param ([switch]$EmitAsError)
    while ($__CrescendoNativeErrorQueue.Count -gt 0) {
        if ($EmitAsError) {
            $msg = $__CrescendoNativeErrorQueue.Dequeue()
            $er = [System.Management.Automation.ErrorRecord]::new([system.invalidoperationexception]::new($msg), $PSCmdlet.Name, "InvalidOperation", $msg)
            $PSCmdlet.WriteError($er)
        }
        else {
            $__CrescendoNativeErrorQueue.Dequeue()
        }
    }
}
# this is purposefully a filter rather than a function for streaming errors
filter Push-CrescendoNativeError {
    if ($_ -is [System.Management.Automation.ErrorRecord]) {
        $__CrescendoNativeErrorQueue.Enqueue($_)
    }
    else {
        $_
    }
}

function Get-IOStat
{
[PowerShellCustomFunctionAttribute(RequiresElevation=$False)]
[CmdletBinding()]

param(
[Parameter()]
[switch]$CPU,
[Parameter()]
[switch]$Device,
[Parameter()]
[switch]$HumanReadable,
[Parameter()]
[switch]$Kilobytes,
[Parameter()]
[switch]$Megabytes,
[Parameter()]
[switch]$Short,
[Parameter()]
[switch]$Time,
[Parameter()]
[switch]$Extended,
[Parameter()]
[switch]$OmitFirst,
[Parameter()]
[switch]$OmitInactive,
[Parameter()]
[switch]$Compact,
[Parameter()]
[string]$DecimalPlaces,
[Parameter()]
[string]$PersistentNameType,
[Parameter()]
[string]$Group,
[Parameter()]
[switch]$GroupOnly,
[Parameter()]
[switch]$Pretty,
[Parameter()]
[string]$Partition,
[Parameter(Position=0)]
[int]$Interval,
[Parameter(Position=1)]
[int]$Count,
[Parameter(Position=2)]
[string]$DeviceList
    )

BEGIN {
    $PSNativeCommandUseErrorActionPreference = $false
    $__CrescendoNativeErrorQueue = [System.Collections.Queue]::new()
    $__PARAMETERMAP = @{
         CPU = @{
               OriginalName = '-c'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Device = @{
               OriginalName = '-d'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         HumanReadable = @{
               OriginalName = '-h'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Kilobytes = @{
               OriginalName = '-k'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Megabytes = @{
               OriginalName = '-m'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Short = @{
               OriginalName = '-s'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Time = @{
               OriginalName = '-t'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Extended = @{
               OriginalName = '-x'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         OmitFirst = @{
               OriginalName = '-y'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         OmitInactive = @{
               OriginalName = '-z'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Compact = @{
               OriginalName = '--compact'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         DecimalPlaces = @{
               OriginalName = '--dec='
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'string'
               ApplyToExecutable = $False
               NoGap = $True
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         PersistentNameType = @{
               OriginalName = '-j'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'string'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Group = @{
               OriginalName = '-g'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'string'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         GroupOnly = @{
               OriginalName = '-H'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Pretty = @{
               OriginalName = '--pretty'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'switch'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Partition = @{
               OriginalName = '-p'
               OriginalPosition = '0'
               Position = '2147483647'
               ParameterType = 'string'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Interval = @{
               OriginalName = ''
               OriginalPosition = '0'
               Position = '0'
               ParameterType = 'int'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         Count = @{
               OriginalName = ''
               OriginalPosition = '0'
               Position = '1'
               ParameterType = 'int'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
         DeviceList = @{
               OriginalName = ''
               OriginalPosition = '0'
               Position = '2'
               ParameterType = 'string'
               ApplyToExecutable = $False
               NoGap = $False
               ArgumentTransform = '$args'
               ArgumentTransformType = 'inline'
               }
    }

    $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input; Pop-CrescendoNativeError -EmitAsError } } }
}

PROCESS {
    $__boundParameters = $PSBoundParameters
    $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name
    $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})
    $__commandArgs = @()
    $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})
    if ($__boundParameters["Debug"]){wait-debugger}
    $__commandArgs += '-o'
    $__commandArgs += 'JSON'
    foreach ($paramName in $__boundParameters.Keys|
            Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|
            Where-Object {!$__PARAMETERMAP[$_].ExcludeAsArgument}|
            Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
        $value = $__boundParameters[$paramName]
        $param = $__PARAMETERMAP[$paramName]
        if ($param) {
            if ($value -is [switch]) {
                 if ($value.IsPresent) {
                     if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
                 }
                 elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
            }
            elseif ( $param.NoGap ) {
                # if a transform is specified, use it and the construction of the values is up to the transform
                if($param.ArgumentTransform -ne '$args') {
                    $transform = $param.ArgumentTransform
                    if($param.ArgumentTransformType -eq 'inline') {
                        $transform = [scriptblock]::Create($param.ArgumentTransform)
                    }
                    $__commandArgs += & $transform $value
                }
                else {
                    $pFmt = "{0}{1}"
                    # quote the strings if they have spaces
                    if($value -match "\s") { $pFmt = "{0}""{1}""" }
                    $__commandArgs += $pFmt -f $param.OriginalName, $value
                }
            }
            else {
                if($param.OriginalName) { $__commandArgs += $param.OriginalName }
                if($param.ArgumentTransformType -eq 'inline') {
                   $transform = [scriptblock]::Create($param.ArgumentTransform)
                }
                else {
                   $transform = $param.ArgumentTransform
                }
                $__commandArgs += & $transform $value
            }
        }
    }
    $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}
    if ($__boundParameters["Debug"]){wait-debugger}
    if ( $__boundParameters["Verbose"]) {
         Write-Verbose -Verbose -Message "/usr/bin/iostat"
         $__commandArgs | Write-Verbose -Verbose
    }
    $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
    if (! $__handlerInfo ) {
        $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
    }
    $__handler = $__handlerInfo.Handler
    if ( $PSCmdlet.ShouldProcess("/usr/bin/iostat $__commandArgs")) {
    # check for the application and throw if it cannot be found
        if ( -not (Get-Command -ErrorAction Ignore "/usr/bin/iostat")) {
          throw "Cannot find executable '/usr/bin/iostat'"
        }
        if ( $__handlerInfo.StreamOutput ) {
            if ( $null -eq $__handler ) {
                & "/usr/bin/iostat" $__commandArgs
            }
            else {
                & "/usr/bin/iostat" $__commandArgs 2>&1| Push-CrescendoNativeError | & $__handler
            }
        }
        else {
            $result = & "/usr/bin/iostat" $__commandArgs 2>&1| Push-CrescendoNativeError
            & $__handler $result
        }
    }
    # be sure to let the user know if there are any errors
    Pop-CrescendoNativeError -EmitAsError
  } # end PROCESS

<#
.SYNOPSIS
Retrieves system I/O and CPU statistics in JSON format for performance monitoring and analysis.

.DESCRIPTION
A PowerShell wrapper for the iostat utility.

Use this command to monitor CPU usage and device input/output activity over time, identify performance bottlenecks, and analyze trends in system resource utilization. Output is always in JSON format for easy integration with other tools and scripts.

.PARAMETER CPU
Display the CPU utilization report.


.PARAMETER Device
Display the device utilization report.


.PARAMETER HumanReadable
Display sizes in a human-readable format (e.g., 1.0k, 1.2M).


.PARAMETER Kilobytes
Display statistics in kilobytes per second.


.PARAMETER Megabytes
Display statistics in megabytes per second.


.PARAMETER Short
Display a short (narrow) version of the report.


.PARAMETER Time
Print the time for each report displayed.


.PARAMETER Extended
Display extended statistics.


.PARAMETER OmitFirst
Omit first report with statistics since system boot.


.PARAMETER OmitInactive
Omit output for devices with no activity.


.PARAMETER Compact
Display all metrics on a single line.


.PARAMETER DecimalPlaces
Specify the number of decimal places (0-2).


.PARAMETER PersistentNameType
Display persistent device names (ID, LABEL, PATH, UUID, etc.).


.PARAMETER Group
Display statistics for a group of devices.


.PARAMETER GroupOnly
Only global statistics for the group (use with -g).


.PARAMETER Pretty
Make the Device Utilization Report easier to read by a human.


.PARAMETER Partition
Display statistics for block devices and all their partitions (device[,device] or ALL).


.PARAMETER Interval
Interval in seconds between each report.


.PARAMETER Count
Number of reports to generate.


.PARAMETER DeviceList
List of devices to report on (space separated).



.EXAMPLE
PS> Get-IOStat -CPU

Shows CPU utilization statistics in JSON format.
Original Command: iostat -c -o JSON


.EXAMPLE
PS> Get-IOStat -Device -HumanReadable

Shows device I/O stats in human-readable JSON format.
Original Command: iostat -d --human -o JSON


.EXAMPLE
PS> Get-IOStat -Device -Interval 2 -Count 3

Shows device I/O stats every 2 seconds, 3 times.
Original Command: iostat -d -o JSON 2 3


.LINK
https://man7.org/linux/man-pages/man1/iostat.1.html

#>
}


