# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMTrackCorrection: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackCorrection'.TrackCorrection

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
            { Get-LFMTrackCorrection -Track $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMTrackCorrection -Track Track -Artist Artist
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
            $output = Get-LFMTrackCorrection -Track Track -Artist Artist
        }

        It 'Should return the correct corrected track name' {
            $output.Track | Should -Be $contextMock.Corrections.Correction.Track.Name
        }

        It 'Should return the correct corrected track url' {
            $output.TrackUrl | Should -Be $contextMock.Corrections.Correction.Track.Url
        }

        It 'Should return the correct corrected track artist name' {
            $output.Artist | Should -Be $contextMock.Corrections.Correction.Track.Artist.Name
        }

        It 'Should return the correct corrected track artist id' {
            $output.ArtistId | Should -Be $contextMock.Corrections.Correction.Track.Artist.Mbid
        }

        It 'Should return the correct corrected track artist url' {
            $output.ArtistUrl | Should -Be $contextMock.Corrections.Correction.Track.Artist.Url
        }

        It 'Corrected track should have one track' {
            $output.Track | Should -HaveCount 1
        }

        It 'Corrected track should not have two tracks' {
            $output.Track | Should -Not -BeNullOrEmpty
            $output.Track | Should -Not -HaveCount 2
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

            { Get-LFMTrackCorrection -Track Track -Artist Artist } | Should -Throw 'Error'
        }
    }
}
