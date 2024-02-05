Describe 'ConvertTo-UnixTime: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
        Set-TimeZone -Id 'W. Europe Standard Time'
    }

    It 'Converts local to UTC when DateTimeKind is local' {
        $date = [datetime]::SpecifyKind('November 14, 2006 08:00:00', 'Local')
        $fakeDate = New-MockObject -InputObject $date

        $unixTime = InModuleScope @module { ConvertTo-UnixTime -Date $date } -Parameters @{ date = $fakeDate }
        $unixTime | Should -Be 1163487600
    }

    It 'Does not convert local to UTC when DateTimeKind is not Local' {
        $date = [datetime]::SpecifyKind('November 14, 2006 08:00:00', 'UTC')
        $fakeDate = New-MockObject -InputObject $date

        $unixTime = InModuleScope @module { ConvertTo-UnixTime -Date $date } -Parameters @{ date = $fakeDate }
        $unixTime | Should -Not -Be 1163487600
    }
}
