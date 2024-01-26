Describe 'ConvertTo-UnixTime: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Converts November 14, 2006 08:00:00 to 1163491200' {
        $unixTime = InModuleScope @module { ConvertTo-UnixTime -Date 'November 14, 2006 08:00:00' }
        $unixTime | Should -Be 1163491200
    }

    It 'Converts November 14, 2006 08:00:00 to 1163487600 when DateTimeKind is Local' {
        $unixTime = InModuleScope @module { ConvertTo-UnixTime -Date $date } -Parameters @{
            date = [datetime]::SpecifyKind('November 14, 2006 08:00:00', 'Local')
        }
        $unixTime | Should -Be 1163487600
    }

    It 'Does not convert November 14, 2006 08:00:00 to 1163487600 when DateTimeKind is not Local' {
        $unixTime = InModuleScope @module { ConvertTo-UnixTime -Date $date } -Parameters @{
            date = [datetime]::SpecifyKind('November 14, 2006 08:00:00', 'Utc')
        }
        $unixTime | Should -Not -Be 1163487600
    }
}
