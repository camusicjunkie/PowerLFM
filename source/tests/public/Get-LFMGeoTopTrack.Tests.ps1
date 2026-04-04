# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMGeoTopTrack: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMGeoTopTrack'.GeoTopTrack

        Mock Remove-CommonParameter {
            [hashtable] @{
                Country = 'Country'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when limit is greater than 119' {
            { Get-LFMGeoTopTrack -Country Country -Limit 120 } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMGeoTopTrack -Country Country
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
            $output = Get-LFMGeoTopTrack -Country Country
        }

        It 'Should return the correct first top track name' {
            $output[0].Track | Should -Be $contextMock.Tracks.Track[0].Name
        }

        It 'Should return the correct first top track artist name' {
            $output[0].Artist | Should -Be $contextMock.Tracks.Track[0].Artist.Name
        }

        It 'Should return the correct first top track id' {
            $output[0].TrackId | Should -Be $contextMock.Tracks.Track[0].Mbid
        }

        It 'Should return the correct first top track listener count' {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.Tracks.Track[0].Listeners
        }

        It 'Should return the correct second top track listener count' {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.Tracks.Track[1].Listeners
        }

        It 'Should return the correct second top track artist id' {
            $output[1].ArtistId | Should -Be $contextMock.Tracks.Track[1].Artist.Mbid
        }

        It 'Should return the correct second top track artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.Tracks.Track[1].Artist.Url
        }

        It 'Should return the correct second top track url' {
            $output[1].TrackUrl | Should -Be $contextMock.Tracks.Track[1].Url
        }

        It 'Country should have two top tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'Country should not have more than two top tracks' {
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

            { Get-LFMGeoTopTrack -Country Country } | Should -Throw 'Error'
        }
    }
}
