Set-StrictMode -Version 3.0

Import-Module Pode
Import-Module Pode.Web

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
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

    Use-PodeWebTemplates -Title 'Service' -Theme Light

    $PodeLogger = New-PodeLoggingMethod -Terminal 
    $PodeLogger | Enable-PodeErrorLogging -Levels Error, Informational, Verbose, Warning
    $PodeLogger | Enable-PodeRequestLogging

    Function Split-LinesBySpace{
        Param(
            [String]$UnixLines
        )
        return $UnixLines.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
    }

    Set-PodeWebHomePage -Layouts @(
        New-PodeWebHero -Title 'Welcome to Your System' -Message 'Home' -Content @(
            New-PodeWebText -Value 'Here is some text!' -InParagraph -Alignment Center
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

    Add-PodeWebPage -Name 'Chat with CodeLama' -Icon 'Settings' -Group 'AI' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebForm -Name 'AI' -Method 'Get'  -ScriptBlock {
                $message = $WebEvent.Data['Message']
            } -Content @(
                New-PodeWebTextbox -Name 'Message' -Multiline
            )  
        )
    }
}