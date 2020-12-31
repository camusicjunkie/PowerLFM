BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Search-LFMTrack: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMTrack'.Track
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMTrack'.Track

        Mock Remove-CommonParameter {
            [hashtable] @{
                Track = 'Track'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when track is null' {
            { Search-LFMTrack -Track $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Search-LFMTrack -Track Track -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Search-LFMTrack -Track Track -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Search-LFMTrack -Track Track
        }

        It 'Should remove common parameters from bound parameters' {
            $siParams = @{
                CommandName     = 'Remove-CommonParameter'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $PSBoundParameters
                }
            }
            Should -Invoke @siParams
        }

        It 'Should convert parameters to format API expects after signing' {
            $siParams = @{
                CommandName = 'ConvertTo-LFMParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }

        It 'Should take hashtable and build a query for a uri' {
            $siParams = @{
                CommandName = 'New-LFMApiQuery'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        BeforeAll {
            $output = Search-LFMTrack -Track Track
        }

        It "Searched first track should have name of $($contextMock.Results.TrackMatches.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.Results.TrackMatches.Track[0].Name
        }

        It "Searched first track should have artist name of $($contextMock.Results.TrackMatches.Track[0].Artist)" {
            $output[0].Artist | Should -Be $contextMock.Results.TrackMatches.Track[0].Artist
        }

        It "Searched first track should have url of $($contextMock.Results.TrackMatches.Track[0].Url)" {
            $output[0].Url | Should -Be $contextMock.Results.TrackMatches.Track[0].Url
        }

        It "Searched first track should have $($contextMock.Results.TrackMatches.Track[0].Listeners) listener" {
            $output[0].Listeners | Should -Be $contextMock.Results.TrackMatches.Track[0].Listeners
        }

        It "Searched second track should have url of $($contextMock.Results.TrackMatches.Track[1].Url)" {
            $output[1].Url | Should -Be $contextMock.Results.TrackMatches.Track[1].Url
        }

        It "Searched second track should have artist id with a value of $($contextMock.Results.TrackMatches.Track[1].Mbid)" {
            $output[1].Id | Should -Be $contextMock.Results.TrackMatches.Track[1].Mbid
        }

        It 'Searched result should have two tracks' {
            $output | Should -HaveCount 2
        }

        It 'Searched result should not have more than two tracks' {
            $output | Should -Not -HaveCount 3
        }

        It 'Should call the correct Last.fm get method' {
            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like "$baseUrl*"
                }
            }
            Should -Invoke @siParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Search-LFMTrack -Track Track } | Should -Throw 'Error'
        }
    }
}
