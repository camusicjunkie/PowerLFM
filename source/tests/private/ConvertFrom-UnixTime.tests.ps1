
Describe 'ConvertFrom-UnixTime: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Converts 1163491200 to November 14, 2006 08:00:00' {
        $time = InModuleScope @module { ConvertFrom-UnixTime -UnixTime 1163491200 }
        '{0} {1}' -f $time.ToLongDateString(), $time.ToLongTimeString() | Should -Be 'Tuesday, November 14, 2006 8:00:00 AM'
    }

    It 'Converts 1163491200 to November 14, 2006 09:00:00 when Local is used' {
        Mock Get-Date { '+01' } -ModuleName PowerLFM
        $time = InModuleScope @module { ConvertFrom-UnixTime -UnixTime 1163491200 -Local }
        '{0} {1}' -f $time.ToLongDateString(), $time.ToLongTimeString() | Should -Be 'Tuesday, November 14, 2006 9:00:00 AM'
    }
}
