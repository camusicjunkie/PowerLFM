Describe 'Test-LFMJson: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    Context 'A JSON object' {
        It 'Is one: <Name>' -ForEach @(
            @{ Name = 'nested object'; Json = '{ "a":1,"b":{"c":3}}' }
            @{ Name = 'an api error body'; Json = '{"error":6,"message":"Album not found"}' }
            @{ Name = 'empty object'; Json = '{}' }
        ) {
            $result = InModuleScope @module -Parameters @{ Json = $Json } { Test-LFMJson -Json $Json }
            $result | Should -BeTrue
        }
    }

    Context 'Anything else' {
        # The caller reads properties off what it parses, so valid JSON that is not an
        # object is no more use to it than a string that never parsed at all.
        It 'Is not: <Name>' -ForEach @(
            @{ Name = 'not json'; Json = 'NotJson' }
            @{ Name = 'truncated object'; Json = '{"a":' }
            @{ Name = 'an array'; Json = '[1,2]' }
            @{ Name = 'a bare number'; Json = '5' }
            @{ Name = 'a bare string'; Json = '"hi"' }
        ) {
            $result = InModuleScope @module -Parameters @{ Json = $Json } { Test-LFMJson -Json $Json }
            $result | Should -BeFalse
        }
    }
}
