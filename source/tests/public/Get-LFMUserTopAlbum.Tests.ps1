# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMUserTopAlbum: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTopAlbum'.UserTopAlbum

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserTopAlbum -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Get-LFMUserTopAlbum -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Get-LFMUserTopAlbum -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserTopAlbum
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
            $output = Get-LFMUserTopAlbum
        }

        It 'Should return the correct first top album name' {
            $output[0].Album | Should -Be $contextMock.TopAlbums.Album[0].Name
        }

        It 'Should return the correct first top album artist name' {
            $output[0].Artist | Should -Be $contextMock.TopAlbums.Album[0].Artist.Name
        }

        It 'Should return the correct first top album url' {
            $output[0].AlbumUrl | Should -Be $contextMock.TopAlbums.Album[0].Url
        }

        It 'Should return the correct first top album play count' {
            $output[0].PlayCount | Should -Be $contextMock.TopAlbums.Album[0].PlayCount
        }

        It 'Should return the correct second top album play count' {
            $output[1].PlayCount | Should -Be $contextMock.TopAlbums.Album[1].PlayCount
        }

        It 'Should return the correct second top album url' {
            $output[1].AlbumUrl | Should -Be $contextMock.TopAlbums.Album[1].Url
        }

        It 'Should return the correct second top album artist id' {
            $output[1].ArtistId | Should -Be $contextMock.TopAlbums.Album[1].Artist.Mbid
        }

        It 'Should return the correct second top album artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.TopAlbums.Album[1].Artist.Url
        }

        It 'User should have two top albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'User should not have more than two top albums' {
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

            { Get-LFMUserTopAlbum } | Should -Throw 'Error'
        }
    }
}
