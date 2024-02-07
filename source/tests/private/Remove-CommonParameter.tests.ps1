Describe 'Remove-CommonParameter: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Removes only the common parameters' {
        $result = InModuleScope @module { Remove-CommonParameter -InputObject $inputObject } -Parameters @{
            inputObject = @{ Verbose = $true; Whatif = $true; Artist = 'Deftones' }
        }
        $result.Keys | Should -Be 'Artist'
        $result.Values | Should -Be 'Deftones'
    }
}
