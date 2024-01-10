BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMArtistTopAlbum: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistTopAlbum'.ArtistTopAlbum
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistTopAlbum'.ArtistTopAlbum

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
            { Get-LFMArtistTopAlbum -Artist $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMArtistTopAlbum -Artist Artist
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
            $output = Get-LFMArtistTopAlbum -Artist Artist
        }

        It "Artist first top album should have name of $($contextMock.TopAlbums.Album[0].Name)" {
            $output[0].Album | Should -Be $contextMock.TopAlbums.Album[0].Name
        }

        It "Artist first top album should have id of $($contextMock.TopAlbums.Album[0].Mbid)" {
            $output[0].Id | Should -Be $contextMock.TopAlbums.Album[0].Mbid
        }

        It "Artist second top album should have url of $($contextMock.TopAlbums.Album[1].Url)" {
            $output[1].Url | Should -Be $contextMock.TopAlbums.Album[1].Url
        }

        It "Artist second top album should have playcount with a value of $($contextMock.TopAlbums.Album[1].PlayCount)" {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.TopAlbums.Album[1].PlayCount
        }

        It 'Artist should have two top albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'Artist should not have more than two top albums' {
            $output.Album | Should -Not -BeNullOrEmpty
            $output.Album | Should -Not -HaveCount 3
        }

        It 'Artist should have two top albums when id parameter is used' {
            $output = Get-LFMArtistTopAlbum -Id (New-Guid)
            $output.Album | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMArtistTopAlbum -Artist Artist

            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
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

            { Get-LFMArtistTopAlbum -Artist Artist } | Should -Throw 'Error'
        }
    }
}
