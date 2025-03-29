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

Start-PodeServer -Threads 2 -EnablePool WebSockets {
    Add-PodeEndpoint -Address localhost -Port 9090 -Protocol Http

    Add-PodeStaticRoute -Path /assets -Source ./Assets
    Add-PodeStaticRoute -Path /themes -Source ./Templates/Public/styles/themes
    
    Use-PodeWebTemplates -Title 'SeraBryx' -Theme Terminal -NoPageFilter
    Import-PodeWebStylesheet -Url 'http://localhost:9090/themes/midnight.css'
    Use-PodeWebPages -Path ./pages

    $PodeLogger = New-PodeLoggingMethod -Terminal 
    $PodeLogger | Enable-PodeErrorLogging -Levels Error, Informational, Verbose, Warning
    $PodeLogger | Enable-PodeRequestLogging

    Function Split-LinesBySpace{
        Param(
            [String]$UnixLines
        )
        return $UnixLines.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
    }

    $OsVersion = [System.Environment]::OSVersion
    $UserName = [System.Environment]::UserName
    $UserDomainName = [System.Environment]::UserDomainName

    Set-PodeWebHomePage -DisplayName "$($UserName)@$($UserDomainName), $($OsVersion)" -Layouts @(
        New-PodeWebGrid -CssClass @{'Font-Family' = 'Anta'} -Cells @(
            New-PodeWebCell -Content @(
                New-PodeWebImage -Id 'SeraBryxImage' -Source ./Assets/SeraBryxLite.svg
            )
            New-PodeWebCell -Content @(
                
                New-PodeWebChart -Name 'CPU' -Type bar -Height '10em' -AutoRefresh -RefreshInterval 1 -AsCard -ScriptBlock {
                    $cpuFromProc = Get-CpuFromProc

                    return @{
                        TotalUsage  = $cpuFromProc.TotalUsage

                    } | ConvertTo-PodeWebChartData -DatasetProperty TotalUsage -LabelProperty TotalUsage
                }
                # New-PodeWebChart -Name 'RAM' -Type 'bar' -Height '10em' -AutoRefresh -RefreshInterval 1 -AsCard -ScriptBlock {
                #     return @{
                #         RAM = Get-RamPercentage
                #     } | ConvertTo-PodeWebChartData -DatasetProperty RAM -LabelProperty RAM
                # }
                # New-PodeWebText -Value "Os: $OsVersion" -InParagraph -Alignment Left
                # New-PodeWebText -Value "Status: $(Get-CpuStatus)" -InParagraph -Alignment Left
            )
            New-PodeWebCell -Content @(
                New-PodeWebCodeEditor -Language Html -Name 'Code Editor' -AsCard -Value '<p style="color:white;">well</p>' -Upload {
                    $WebEvent.Data | Out-Default
                }
            )
        )
    )

    
    
    Add-PodeWebPage -Name 'Processes' -Icon 'Settings' -Group 'System' -ScriptBlock {
        New-PodeWebCard -Content @(
            New-PodeWebTable -Name 'Processes' -ScriptBlock {
                
                $Processes = (Get-Process -IncludeUserName ) | `
                Select-Object -Unique -Property Id, `
                WorkingSet, ProcessName, UserName, `
                @{Name="CommandLine";Expression={("$($_.CommandLine)".Length -le 50) `
                ? "$($_.CommandLine)" : ("$($_.CommandLine)".Substring(0,50)) + "..." }}| `
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


        # Add-PodeWebPage -Name 'Form Test' -Icon 'Settings' -Group 'Testing' -ScriptBlock {
    #     New-PodeWebCard -Content @(
    #         New-PodeWebForm -Name 'Example' -ScriptBlock {
    #                 $WebEvent.Data | Out-Default
    #         } -Content @(
    #             New-PodeWebTextbox -Name 'Name' -AutoComplete {
    #                 return @('billy', 'bobby', 'alice', 'john', 'sarah', 'matt', 'zack', 'henry')
    #             }
    #             New-PodeWebTextbox -Name 'Password' -Type Password -PrependIcon Lock
    #             New-PodeWebTextbox -Name 'Date' -Type Date
    #             New-PodeWebTextbox -Name 'Time' -Type Time
    #             New-PodeWebDateTime -Name 'DateTime' -NoLabels
    #             New-PodeWebCredential -Name 'Credentials' -NoLabels
    #             New-PodeWebCheckbox -Name 'Checkboxes' -Options @('Terms', 'Privacy') -AsSwitch
    #             New-PodeWebRadio -Name 'Radios' -Options @('S', 'M', 'L')
    #             New-PodeWebSelect -Name 'Role' -Options @('User', 'Admin', 'Operations') -Multiple
    #             New-PodeWebRange -Name 'Cores' -Value 30 -ShowValue
    #         )
    #     )
    # }
}