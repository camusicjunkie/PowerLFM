Describe 'New-LFMApiQuery: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    Context 'Query string mode' {

        It 'Builds a basic key=value query string' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject @{ method = 'album.getInfo' }
            }
            $result | Should -Be 'method=album.getInfo'
        }

        It 'Joins multiple key=value pairs with &' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject ([ordered] @{ method = 'artist.getInfo'; format = 'json' })
            }
            $result | Should -Be 'method=artist.getInfo&format=json'
        }

        It 'URL encodes special characters in values' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject @{ artist = 'AC/DC' }
            }
            $result | Should -Be 'artist=AC%2FDC'
        }

        It 'URL encodes spaces in values' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject @{ artist = 'Nine Inch Nails' }
            }
            $result | Should -Be 'artist=Nine%20Inch%20Nails'
        }

        It 'URL encodes ampersands in values' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject @{ artist = 'Simon & Garfunkel' }
            }
            $result | Should -Be 'artist=Simon%20%26%20Garfunkel'
        }
    }

    Context 'Signature mode' {

        It 'Concatenates key and value with no separator' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject @{ method = 'album.getInfo' } -Signature
            }
            $result | Should -Be 'methodalbum.getInfo'
        }

        It 'Sorts keys alphabetically in signature mode' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject @{ method = 'album.getInfo'; api_key = 'abc123' } -Signature
            }
            $result | Should -Be 'api_keyabc123methodalbum.getInfo'
        }

        It 'Does not URL encode values in signature mode' {
            $result = InModuleScope @module {
                New-LFMApiQuery -InputObject @{ artist = 'AC/DC' } -Signature
            }
            $result | Should -Be 'artistAC/DC'
        }
    }
}
