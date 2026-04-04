# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Search-LFMAlbum: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMAlbum'.Album

        Mock Remove-CommonParameter {
            [hashtable] @{
                Album = 'Album'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when album is null' {
            { Search-LFMAlbum -Album $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Search-LFMAlbum -Album Album -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Search-LFMAlbum -Album Album -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Search-LFMAlbum -Album Album
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
            $output = Search-LFMAlbum -Album Album
        }

        It 'Should return the correct first searched album name' {
            $output[0].Album | Should -Be $contextMock.Results.AlbumMatches.Album[0].Name
        }

        It 'Should return the correct first searched album artist name' {
            $output[0].Artist | Should -Be $contextMock.Results.AlbumMatches.Album[0].Artist
        }

        It 'Should return the correct first searched album url' {
            $output[0].Url | Should -Be $contextMock.Results.AlbumMatches.Album[0].Url
        }

        It 'Should return the correct second searched album url' {
            $output[1].Url | Should -Be $contextMock.Results.AlbumMatches.Album[1].Url
        }

        It 'Should return the correct second searched album id' {
            $output[1].Id | Should -Be $contextMock.Results.AlbumMatches.Album[1].Mbid
        }

        It 'Searched result should have two albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'Searched result should not have more than two albums' {
            $output.Album | Should -Not -BeNullOrEmpty
            $output.Album | Should -Not -HaveCount 3
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

            { Search-LFMAlbum -Album Album } | Should -Throw 'Error'
        }
    }
}
