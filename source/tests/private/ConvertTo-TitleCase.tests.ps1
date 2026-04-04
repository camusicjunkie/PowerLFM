Describe 'ConvertTo-TitleCase: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Converts a single lowercase string to title case' {
        $result = InModuleScope @module { ConvertTo-TitleCase -String 'rock' }
        $result | Should -Be 'Rock'
    }

    It 'Converts a multi-word string to title case' {
        $result = InModuleScope @module { ConvertTo-TitleCase -String 'alternative rock' }
        $result | Should -Be 'Alternative Rock'
    }

    It 'Accepts a single string via pipeline' {
        $result = InModuleScope @module { 'indie pop' | ConvertTo-TitleCase }
        $result | Should -Be 'Indie Pop'
    }

    It 'Processes each string in an array separately' {
        $result = InModuleScope @module { ConvertTo-TitleCase -String @('rock', 'pop', 'jazz') }
        $result | Should -HaveCount 3
        $result[0] | Should -Be 'Rock'
        $result[1] | Should -Be 'Pop'
        $result[2] | Should -Be 'Jazz'
    }

    It 'Processes multiple pipeline inputs individually' {
        $result = InModuleScope @module { @('rock', 'pop') | ConvertTo-TitleCase }
        $result | Should -HaveCount 2
        $result[0] | Should -Be 'Rock'
        $result[1] | Should -Be 'Pop'
    }
}
