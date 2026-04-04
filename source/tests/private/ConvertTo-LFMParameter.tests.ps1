Describe 'ConvertTo-LFMParameter: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    Context 'Key mapping' {

        It 'Maps Artist to artist' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Artist = 'Test' }
            }
            $result['artist'] | Should -Be 'Test'
        }

        It 'Maps Album to album' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Album = 'Test' }
            }
            $result['album'] | Should -Be 'Test'
        }

        It 'Maps UserName to user' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ UserName = 'TestUser' }
            }
            $result['user'] | Should -Be 'TestUser'
        }

        It 'Maps Limit to limit' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Limit = 10 }
            }
            $result['limit'] | Should -Be 10
        }

        It 'Maps Page to page' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Page = 2 }
            }
            $result['page'] | Should -Be 2
        }
    }

    Context 'Date conversion' {

        It 'Converts Timestamp using its own InputObject value' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Timestamp = [datetime]'2023-01-01 00:00:00Z' }
            }
            $result['timestamp'] | Should -BeOfType [long]
            $result['timestamp'] | Should -BeGreaterThan 0
        }

        It 'Converts StartDate using its own InputObject value' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ StartDate = [datetime]'2023-01-01 00:00:00Z' }
            }
            $result['from'] | Should -BeOfType [long]
            $result['from'] | Should -BeGreaterThan 0
        }

        It 'Converts EndDate using its own InputObject value' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ EndDate = [datetime]'2023-06-01 00:00:00Z' }
            }
            $result['to'] | Should -BeOfType [long]
            $result['to'] | Should -BeGreaterThan 0
        }

        It 'Converts StartDate and EndDate to different values when dates differ' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{
                    StartDate = [datetime]'2023-01-01 00:00:00Z'
                    EndDate   = [datetime]'2023-06-01 00:00:00Z'
                }
            }
            $result['from'] | Should -BeLessThan $result['to']
        }
    }

    Context 'TimePeriod translation' {

        It "Translates '7 Days' to '7day'" {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ TimePeriod = '7 Days' }
            }
            $result['period'] | Should -Be '7day'
        }

        It "Translates '1 Month' to '1month'" {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ TimePeriod = '1 Month' }
            }
            $result['period'] | Should -Be '1month'
        }

        It "Translates '1 Year' to '12month'" {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ TimePeriod = '1 Year' }
            }
            $result['period'] | Should -Be '12month'
        }

        It "Translates 'Overall' to 'overall'" {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ TimePeriod = 'Overall' }
            }
            $result['period'] | Should -Be 'overall'
        }
    }

    Context 'Key removal' {

        It 'Removes Method from the output' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Artist = 'Test'; Method = 'album.getTags' }
            }
            $result.ContainsKey('method') | Should -BeFalse
            $result.ContainsKey('Method') | Should -BeFalse
        }

        It 'Removes SharedSecret from the output' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Artist = 'Test'; SharedSecret = 'secret' }
            }
            $result.ContainsKey('SharedSecret') | Should -BeFalse
        }

        It 'Removes PassThru from the output' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Artist = 'Test'; PassThru = $true }
            }
            $result.ContainsKey('PassThru') | Should -BeFalse
        }

        It 'Keeps other parameters after removing internal ones' {
            $result = InModuleScope @module {
                ConvertTo-LFMParameter -InputObject @{ Artist = 'Test'; Method = 'test'; SharedSecret = 'secret' }
            }
            $result['artist'] | Should -Be 'Test'
        }
    }
}
