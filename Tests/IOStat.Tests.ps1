# Tests for Get-IOStat (Crescendo iostat wrapper)
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}

Describe 'Get-IOStat Function Test' {
    It 'Should return CPU statistics with -CPU' {
        $result = Get-IOStat -CPU | ConvertFrom-Json
        $result.sysstat.hosts.statistics[0].'avg-cpu' | Should -Not -BeNullOrEmpty
    }

    It 'Should return device statistics with -Device' {
        $result = Get-IOStat -Device | ConvertFrom-Json
        $result.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should return human readable output with -HumanReadable' {
        $result = Get-IOStat -Device -HumanReadable | ConvertFrom-Json
        $result.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should support -KibiBytes and -MebiBytes switches' {
        $kb = Get-IOStat -Device -KibiBytes | ConvertFrom-Json
        $mb = Get-IOStat -Device -MebiBytes | ConvertFrom-Json
        $kb.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
        $mb.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should support -Short and -Extended switches' {
        $short = Get-IOStat -Device -Short | ConvertFrom-Json
        $ext = Get-IOStat -Device -Extended | ConvertFrom-Json
        $short.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
        $ext.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should support -OmitFirst and -OmitInactive switches' {
        $omitFirst = Get-IOStat -Device -OmitFirst | ConvertFrom-Json
        $omitInactive = Get-IOStat -Device -OmitInactive | ConvertFrom-Json
        $omitFirst.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
        $omitInactive.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should support --compact and --pretty switches' {
        $compact = Get-IOStat -Device -Compact | ConvertFrom-Json
        $pretty = Get-IOStat -Device -Pretty | ConvertFrom-Json
        $compact.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
        $pretty.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should support --dec parameter' {
        $dec = Get-IOStat -Device -DecimalPlaces 1 | ConvertFrom-Json
        $dec.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should support -Interval and -Count positional parameters' {
        $interval = Get-IOStat -Device -Interval 1 -Count 1 | ConvertFrom-Json
        $interval.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    It 'Should support -Partition parameter' {
        $all = Get-IOStat -Device -Partition 'ALL' | ConvertFrom-Json
        $all.sysstat.hosts.statistics[0].disk | Should -Not -BeNullOrEmpty
    }

    # Note: -PersistentNameType, -Group, -GroupOnly are hard to test generically without specific system config
    # These can be tested with specific values if needed
}
