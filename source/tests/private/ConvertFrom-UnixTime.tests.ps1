
Describe 'ConvertFrom-UnixTime: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
        Set-TimeZone -Id 'W. Europe Standard Time'
    }

    It 'Converts UnixTime to November 14, 2006 08:00:00' {
        $time = InModuleScope @module { ConvertFrom-UnixTime -UnixTime 1163491200 }
        $time.DateTime | Should -Be 'Tuesday, November 14, 2006 8:00:00 AM'
    }

    It 'Converts UnixTime to November 14, 2006 09:00:00 when Local is used' {
        $time = InModuleScope @module { ConvertFrom-UnixTime -UnixTime 1163491200 -Local }
        $time.DateTime | Should -Be 'Tuesday, November 14, 2006 9:00:00 AM'
    }
}
