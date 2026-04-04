# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMTrackInfo: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackInfo'.TrackInfo

        Mock Remove-CommonParameter {
            [hashtable] @{
                Track  = 'Track'
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when track is null' {
            { Get-LFMTrackInfo -Track $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMTrackInfo -Track Track -Artist Artist
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
            $output = Get-LFMTrackInfo -Track Track -Artist Artist
        }

        It 'Should return the correct track name' {
            $output.Track | Should -Be $contextMock.Track.Name
        }

        It 'Should return the correct artist name' {
            $output.Artist | Should -Be $contextMock.Track.Artist.Name
        }

        It 'Should return the correct album name' {
            $output.Album | Should -Be $contextMock.Track.Album.Title
        }

        It 'Should return the correct track url' {
            $output.Url | Should -Be $contextMock.Track.Url
        }

        It 'Should return the correct listener count' {
            $output.Listeners | Should -BeOfType [int]
            $output.Listeners | Should -Be $contextMock.Track.Listeners
        }

        It 'Should return the correct play count' {
            $output.PlayCount | Should -BeOfType [int]
            $output.PlayCount | Should -Be $contextMock.Track.PlayCount
        }

        It 'Should return the correct first tag name' {
            $output.Tags[0].Tag | Should -Be $contextMock.Track.TopTags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output.Tags[1].Url | Should -Be $contextMock.Track.TopTags.Tag[1].Url
        }

        It 'Track should have two tags' {
            $output.Tags | Should -HaveCount 2
        }

        It 'Track should not have more than two tags' {
            $output.Tags | Should -Not -BeNullOrEmpty
            $output.Tags | Should -Not -HaveCount 3
        }

        It 'Should return the correct user play count' {
            $output = Get-LFMTrackInfo -Track Track -Artist Artist -UserName camusicjunkie
            $output.UserPlayCount | Should -Be $contextMock.Track.UserPlayCount
        }

        It 'Track should have two tags when id parameter is used' {
            $output = Get-LFMTrackInfo -Id (New-Guid)
            $output.Tags | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMTrackInfo -Track Track -Artist Artist

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

            { Get-LFMTrackInfo -Track Track -Artist Artist } | Should -Throw 'Error'
        }
    }
}
