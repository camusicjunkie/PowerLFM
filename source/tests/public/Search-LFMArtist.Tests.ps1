# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Search-LFMArtist: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMArtist'.Artist
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMArtist'.Artist

        Mock Remove-CommonParameter {
            [hashtable] @{
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when artist is null' {
            { Search-LFMArtist -Artist $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Search-LFMArtist -Artist Artist -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Search-LFMArtist -Artist Artist -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Search-LFMArtist -Artist Artist
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
            $output = Search-LFMArtist -Artist Artist
        }

        It "Searched first artist should have name of $($contextMock.Results.ArtistMatches.Artist[0].Name)" {
            $output[0].Artist | Should -Be $contextMock.Results.ArtistMatches.Artist[0].Name
        }

        It "Searched first artist should have $($contextMock.Results.ArtistMatches.Artist[0].Listeners) listener" {
            $output[0].Listeners | Should -Be $contextMock.Results.ArtistMatches.Artist[0].Listeners
        }

        It "Searched first artist should have url of $($contextMock.Results.ArtistMatches.Artist[0].Url)" {
            $output[0].Url | Should -Be $contextMock.Results.ArtistMatches.Artist[0].Url
        }

        It "Searched second artist should have url of $($contextMock.Results.ArtistMatches.Artist[1].Url)" {
            $output[1].Url | Should -Be $contextMock.Results.ArtistMatches.Artist[1].Url
        }

        It "Searched second artist should have artist id with a value of $($contextMock.Results.ArtistMatches.Artist[1].Mbid)" {
            $output[1].Id | Should -Be $contextMock.Results.ArtistMatches.Artist[1].Mbid
        }

        It 'Searched result should have two artists' {
            $output | Should -Not -BeNullOrEmpty
            $output | Should -HaveCount 2
        }

        It 'Searched result should not have more than two artists' {
            $output | Should -Not -BeNullOrEmpty
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

            { Search-LFMArtist -Artist Artist } | Should -Throw 'Error'
        }
    }
}
