#Requires -Modules Pester
using namespace System
Set-StrictMode -Version 3.0

BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
    #$ModuleRoot/Public/ByteMapper.ps1
    Import-Module Graphical
}

Describe 'Graphical' {
    Context 'Test cpu graph with sysbench' {
        It 'Should show a spike then drop' {
            Start-ThreadJob -ScriptBlock {
                if (Test-Path '/usr/bin/sysbench') {
                    Write-Information 'Running sysbench cpu run --threads=2'
                    sysbench cpu run --threads=2 --time=5
                    sysbench cpu run --threads=3 --time=2
                    sysbench cpu run --threads=4 --time=3
                    sysbench cpu run --threads=5 --time=4
                }
            }
            Write-Information 'Taking Cpu samples'
            $CpuSamples = 1..20 | ForEach-Object {
                (Get-CpuFromProc -SampleInterval 1).TotalUsage
            }

            Show-Graph -Datapoints $CpuSamples -YAxisTitle '%' -XAxisTitle 'Time' -YAxisStep 10 -GraphTitle 'Cpu' -XAxisStep 6
        }

    }
    Context 'Test memory graph with sysbench' {
        It 'Should show a memory spike then drop' {
            Start-ThreadJob -ScriptBlock {
                if(Test-Path '/usr/bin/sysbench'){
                    sysbench memory run --threads=6 --time=6
                    Start-Sleep -Seconds 2
                    sysbench memory run --threads=5 --time=1
                    Start-Sleep -Seconds 1
                    sysbench memory run --threads=3 --time=5
                    Start-Sleep -Seconds 4
                }
            }
            $MemorySamples = 1..20 | ForEach-Object {
                (Get-Memory).UsedPercent
                Start-Sleep -Seconds 1
            }
            Show-Graph -Datapoints $MemorySamples -YAxisTitle '%' -XAxisTitle 'Time' -YAxisStep 10 -GraphTitle 'Memory' -XAxisStep 6
        }
    }
}
