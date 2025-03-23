Set-StrictMode -Version 3.0

Import-Module Pode
Import-Module Pode.Web

Get-ChildItem -Path ./App -File -Recurse | ForEach-Object {
    if(($_.Extension -eq ".ps1") -and -not ($_.FullName.Contains(".Tests.ps1"))) {
            Import-Module $_.FullName -Global -Force
    }
}


@{
    Web = @{
        Static = @{
            Cache = @{
                Enable = $true
            }
        }
    }
}

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 9090 -Protocol Http

    Use-PodeWebTemplates -Title 'Service' -Theme Dark

    $PodeLogger = New-PodeLoggingMethod -Terminal 
    $PodeLogger | Enable-PodeErrorLogging -Levels Error, Informational, Verbose, Warning
    $PodeLogger | Enable-PodeRequestLogging

    Function Split-LinesBySpace{
        Param(
            [String]$UnixLines
        )
        return $UnixLines.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
    }

    $InxiOutput = (inxi) | ConvertTo-Json
    $Hostname = (hostname)
    $Whoami = (whoami)

    Set-PodeWebHomePage -Layouts @(
        New-PodeWebHero -Title "Welcome to PowerNixx" -Message "$($Whoami)@$($Hostname)" -Content @(
            New-PodeWebText -Value "$($InxiOutput)" -InParagraph -Alignment Left
        )
    )

    Add-PodeWebPage -Name 'Processes' -Icon 'Settings' -Group 'System' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Processes' -ScriptBlock {
                
                $Processes = (Get-Process -IncludeUserName ) | `
                Select-Object -Unique -Property Id, `
                WorkingSet, ProcessName, UserName, `
                @{Name="CommandLine";Expression={("$($_.CommandLine)".Length -le 100) `
                ? "$($_.CommandLine)" : ("$($_.CommandLine)".Substring(0,99)) + "..." }}| `
                Sort-Object -Descending WorkingSet -Top 30
                
                foreach ($Ps in ($Processes)) {
                    [ordered]@{
                        Id   = $Ps.Id
                        Memory = $Ps.WorkingSet
                        Name = $Ps.ProcessName
                        User = $Ps.UserName
                        Cmd = $Ps.CommandLine
                    }
                }
            }
        )
    }
    
    Add-PodeWebPage -Name 'Posture' -Icon 'Settings' -Group 'System' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Posture' -ScriptBlock {
                
                $SystemdAnalyzeSecurity = (systemd-analyze --json=short security)
                $Services = $SystemdAnalyzeSecurity | ConvertFrom-Json

                foreach($Srv in $Services) {
                    [ordered]@{
                        Service = $Srv.unit
                        Exposure = $Srv.exposure
                        Predicate = $Srv.predicate
                        Happy = $Srv.happy
                    }
                }
            }
        )
    }

    Add-PodeWebPage -Name 'Service Paths' -Icon 'Settings' -Group 'System' -ScriptBlock {
        New-PodeWebCard -Content  @(
            New-PodeWebTable -Name 'Service Paths' -ScriptBlock {
                $SystemdUnitPaths = (systemd-analyze unit-paths)

                $ServicePaths = $SystemdUnitPaths.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

                foreach($UnixPath in $ServicePaths) {
                    [ordered]@{
                        Path = $UnixPath
                    }
                }
            }
        )
    }

    Add-PodeWebPage -Name 'Failed Units' -Icon 'Settings' -Group 'System' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Failed Units' -ScriptBlock {
                $FailedUnitPaths = (systemctl status --failed)

                foreach($fail in $FailedUnitPaths) {
                    [ordered]@{
                        Failed = $fail
                    }
                }
            }
        )
    } 

    Add-PodeWebPage -Name 'Apt Manual Installs' -Icon 'Settings' -Group 'Package' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Apt Manual Installs' -ScriptBlock {
                $ManuallyInstalledPackages = (apt-mark showmanual)
                $Packages = Split-LinesBySpace $ManuallyInstalledPackages

                foreach($P in $Packages) {
                    [ordered]@{
                        Package = $P
                    }
                }
            }
        )
    }

    Add-PodeWebPage -Name 'Approved Verbs' -Icon 'Settings' -Group 'Help' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Approved Verbs' -ScriptBlock{
                $Verbs = Get-Verb

                foreach($Verb in $Verbs) {
                    [ordered]@{
                        Verb = $Verb.Verb
                        Alias = $Verb.AliasPrefix
                        Group = $Verb.Group
                        Description = $Verb.Description
                    }
                }
            }
        )
    }

    Add-PodeWebPage -Name 'PowerShellGet' -Icon 'Settings' -Group 'Package' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'PowerShellGet' -ScriptBlock{
                $Packages = Get-Package -AllVersions

                foreach($Package in $Packages) {
                    [ordered]@{
                        Name = $Package.Name
                        Version = $Package.Version
                        Source = $Package.Source
                        Provider = $Package.Provider

                    }
                }
            }
        )
    }

    Add-PodeWebPage -NoTitle -Name 'Chat' -Icon 'Settings' -Group 'AI' -ScriptBlock {    
        New-PodeWebIFrame -CssStyle @{ Height = '70rem' }  -Url 'http://localhost:8080'
    }

    Add-PodeWebPage -Name 'Form Test' -Icon 'Settings' -Group 'Testing' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebForm -Name 'Example' -ScriptBlock {
                    $WebEvent.Data | Out-Default
            } -Content @(
                New-PodeWebTextbox -Name 'Name' -AutoComplete {
                    return @('billy', 'bobby', 'alice', 'john', 'sarah', 'matt', 'zack', 'henry')
                }
                New-PodeWebTextbox -Name 'Password' -Type Password -PrependIcon Lock
                New-PodeWebTextbox -Name 'Date' -Type Date
                New-PodeWebTextbox -Name 'Time' -Type Time
                New-PodeWebDateTime -Name 'DateTime' -NoLabels
                New-PodeWebCredential -Name 'Credentials' -NoLabels
                New-PodeWebCheckbox -Name 'Checkboxes' -Options @('Terms', 'Privacy') -AsSwitch
                New-PodeWebRadio -Name 'Radios' -Options @('S', 'M', 'L')
                New-PodeWebSelect -Name 'Role' -Options @('User', 'Admin', 'Operations') -Multiple
                New-PodeWebRange -Name 'Cores' -Value 30 -ShowValue
            )
        )
    }

    Add-PodeWebPage -Name 'Log Files' -Icon 'Settings' -Group 'Logs' -ScriptBlock {
        $logfile = $WebEvent.Query['logfile']

        if([string]::IsNullOrWhiteSpace($logfile)){
            New-PodeWebCard -Content @(
                New-PodeWebTable -Name 'Log Files' -ScriptBlock {
                    [LogFileManager]::AddAll()
                    $VarLogs = [LogFileManager]::GetAll()
                    foreach($Log in $VarLogs) {
                        [ordered]@{
                            Log = New-PodeWebLink -Source "/groups/Logs/pages/Log_Files?logfile=$($Log)" -Value $Log
                        }
                    }
                }
            )
        } else {
            $log = (Get-Content -Path "$($logfile)" -Encoding utf8) | ConvertTo-Json
            
            New-PodeWebCard -Name "Log File View" -Content @(
                $log | ConvertFrom-Json | ForEach-Object {
                    New-PodeWebText -Value $_
                    New-PodeWebLine
                }
            )
        }
        
    }
}