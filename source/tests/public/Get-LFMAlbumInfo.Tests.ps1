# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }

Describe 'Get-LFMAlbumInfo: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMAlbumInfo'.AlbumInfo

        Mock Remove-CommonParameter {
            [hashtable] @{
                Album  = 'Album'
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when album is null' {
            { Get-LFMAlbumInfo -Album $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMAlbumInfo -Album Album -Artist Artist
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
            $output = Get-LFMAlbumInfo -Album Album -Artist Artist
        }

        It 'Should return the correct album name' {
            $output.Album | Should -Be $contextMock.Album.Name
        }

        It 'Should return the correct artist name' {
            $output.Artist | Should -Be $contextMock.Album.Artist
        }

        It 'Should return the correct album id' {
            $output.Id | Should -Be $contextMock.Album.Mbid
        }

        It 'Should return the correct album url' {
            $output.Url | Should -Be $contextMock.Album.Url
        }

        It 'Should return the correct listener count' {
            $output.Listeners | Should -BeOfType [int]
            $output.Listeners | Should -Be $contextMock.Album.Listeners
        }

        It 'Should return the correct play count' {
            $output.PlayCount | Should -BeOfType [int]
            $output.PlayCount | Should -Be $contextMock.Album.PlayCount
        }

        It 'Should return the correct first track name' {
            $output.Tracks[0].Track | Should -Be $contextMock.Album.Tracks.Track[0].Name
        }

        It 'Should return the correct second track duration' {
            $output.Tracks[1].Duration | Should -Be $contextMock.Album.Tracks.Track[1].Duration
        }

        It 'Album should have two tracks' {
            $output.Tracks | Should -HaveCount 2
        }

        It 'Album should not have more than two tracks' {
            $output.Tracks | Should -Not -BeNullOrEmpty
            $output.Tracks | Should -Not -HaveCount 3
        }

        It 'Should return the correct first tag name' {
            $output.Tags[0].Tag | Should -Be $contextMock.Album.Tags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output.Tags[1].Url | Should -Be $contextMock.Album.Tags.Tag[1].Url
        }

        It 'Album should have two tags' {
            $output.Tags | Should -HaveCount 2
        }

        It 'Album should not have more than two tags' {
            $output.Tags | Should -Not -HaveCount 3
        }

        It 'Should return the correct album summary' {
            $output.Summary | Should -BeExactly $contextMock.Album.Wiki.Summary
        }

        It 'Should return the correct user play count' {
            $output = Get-LFMAlbumInfo -Artist Artist -Album Album -UserName camusicjunkie
            $output.UserPlayCount | Should -Be $contextMock.Album.UserPlayCount
        }

        It 'Album should have two tracks when id parameter is used' {
            $output = Get-LFMAlbumInfo -Id (New-Guid)
            $output.Tracks | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMAlbumInfo -Album Album -Artist Artist

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

            { Get-LFMAlbumInfo -Album Album -Artist Artist } | Should -Throw 'Error'
        }
    }
}
