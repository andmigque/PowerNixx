Add-PodeWebPage -Name 'File Stream' -Icon 'file' -Group 'System' -ScriptBlock {
    New-PodeWebContainer -Content @(
        New-PodeWebButton -Name 'Stop' -ScriptBlock {
            Stop-PodeWebFileStream -Name 'fs'
        }
        New-PodeWebButton -Name 'Start' -ScriptBlock {
            Start-PodeWebFileStream -Name 'fs'
        }
        New-PodeWebButton -Name 'Restart' -ScriptBlock {
            Restart-PodeWebFileStream -Name 'fs'
        }
        New-PodeWebButton -Name 'Clear' -ScriptBlock {
            Clear-PodeWebFileStream -Name 'fs'
        }
        New-PodeWebButton -Name 'Update 1' -ScriptBlock {
            Update-PodeWebFileStream -Name 'fs' -Url '/logs/error.log'
        }
        New-PodeWebButton -Name 'Update 2' -ScriptBlock {
            Update-PodeWebFileStream -Name 'fs' -Url '/logs/error2.log'
        }
        New-PodeWebFileStream -Name 'fs' -Url '/var/log/syslog' -Icon 'file'
    )

}


