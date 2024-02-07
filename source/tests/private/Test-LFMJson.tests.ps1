Describe 'Test-LFMJson: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Parses valid json' {
        $result = InModuleScope @module { Test-LFMJson -Json '{ "a":1,"b":{"c":3}}' }
        $result | Should -BeTrue
    }

    It 'Does not parse invalid json' {
        $result = InModuleScope @module { Test-LFMJson -Json 'NotJson' }
        $result | Should -BeFalse
    }
}
