# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMTagTopTrack: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagTopTrack'.TagTopTrack

        Mock Remove-CommonParameter {
            [hashtable] @{
                Tag = 'Tag'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when tag is null' {
            { Get-LFMTagTopTrack -Tag $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMTagTopTrack -Tag Tag
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
            $output = Get-LFMTagTopTrack -Tag Tag
        }

        It 'Should return the correct first top track name' {
            $output[0].Track | Should -Be $contextMock.Tracks.Track[0].Name
        }

        It 'Should return the correct first top track artist name' {
            $output[0].Artist | Should -Be $contextMock.Tracks.Track[0].Artist.Name
        }

        It 'Should return the correct first top track url' {
            $output[0].TrackUrl | Should -Be $contextMock.Tracks.Track[0].Url
        }

        It 'Should return the correct first top track rank' {
            $output[0].Rank | Should -Be $contextMock.Tracks.Track[0].'@attr'.Rank
        }

        It 'Should return the correct second top track duration' {
            $output[1].Duration | Should -Be $contextMock.Tracks.Track[1].Duration
        }

        It 'Should return the correct second top track url' {
            $output[1].TrackUrl | Should -Be $contextMock.Tracks.Track[1].Url
        }

        It 'Should return the correct second top track artist id' {
            $output[1].ArtistId | Should -Be $contextMock.Tracks.Track[1].Artist.Mbid
        }

        It 'Should return the correct second top track artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.Tracks.Track[1].Artist.Url
        }

        It 'Tag should have two top tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'Tag should not have more than two top tracks' {
            $output.Track | Should -Not -BeNullOrEmpty
            $output.Track | Should -Not -HaveCount 3
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

            { Get-LFMTagTopTrack -Tag Tag } | Should -Throw 'Error'
        }
    }
}
