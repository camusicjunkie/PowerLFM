Describe 'ConvertTo-TitleCase: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Converts a single lowercase string to title case' {
        $result = InModuleScope @module { ConvertTo-TitleCase -String 'rock' }
        $result | Should -BeExactly 'Rock'
    }

    It 'Converts a multi-word string to title case' {
        $result = InModuleScope @module { ConvertTo-TitleCase -String 'alternative rock' }
        $result | Should -BeExactly 'Alternative Rock'
    }

    It 'Accepts a single string via pipeline' {
        $result = InModuleScope @module { 'indie pop' | ConvertTo-TitleCase }
        $result | Should -BeExactly 'Indie Pop'
    }

    It 'Processes each string in an array separately' {
        $result = InModuleScope @module { ConvertTo-TitleCase -String @('rock', 'pop', 'jazz') }
        $result | Should -HaveCount 3
        $result[0] | Should -BeExactly 'Rock'
        $result[1] | Should -BeExactly 'Pop'
        $result[2] | Should -BeExactly 'Jazz'
    }

    It 'Processes multiple pipeline inputs individually' {
        $result = InModuleScope @module { @('rock', 'pop') | ConvertTo-TitleCase }
        $result | Should -HaveCount 2
        $result[0] | Should -BeExactly 'Rock'
        $result[1] | Should -BeExactly 'Pop'
    }
}
