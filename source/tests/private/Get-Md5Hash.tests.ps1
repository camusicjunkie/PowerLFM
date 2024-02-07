Describe 'Test-LFMJson: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Creates a valid md5 hash' {
        $hash = InModuleScope @module { Get-Md5Hash -String 'PowerLFM' }
        $hash | Should -Be 25763EF5113A5A96D68AA72C47E9D889
    }
}
