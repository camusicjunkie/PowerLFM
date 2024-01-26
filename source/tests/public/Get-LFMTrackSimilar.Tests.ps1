# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMTrackSimilar: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackSimilar'.TrackSimilar
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackSimilar'.TrackSimilar

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
            { Get-LFMTrackSimilar -Track $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMTrackSimilar -Track Track -Artist Artist
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
            $output = Get-LFMTrackSimilar -Track Track -Artist Artist
        }

        It "Track first similar track should have name of $($contextMock.SimilarTracks.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.SimilarTracks.Track[0].Name
        }

        It "Track first similar track match should have value of $($contextMock.SimilarTracks.Track[0].Match)" {
            $output[0].Match | Should -Be $contextMock.SimilarTracks.Track[0].Match
        }

        It "Track first similar track should have an artist name of $($contextMock.SimilarTracks.Track[0].Artist.Name)" {
            $output[0].Artist | Should -Be $contextMock.SimilarTracks.Track[0].Artist.Name
        }

        It "Track second similar track match should have value of $($contextMock.SimilarTracks.Track[1].Match)" {
            $output[1].Match | Should -Be $contextMock.SimilarTracks.Track[1].Match
        }

        It "Track second similar track should have url of $($contextMock.SimilarTracks.Track[1].Url)" {
            $output[1].Url | Should -Be $contextMock.SimilarTracks.Track[1].Url
        }

        It 'Track should have two similar tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'Track should not have more than two similar tracks' {
            $output.Track | Should -Not -BeNullOrEmpty
            $output.Track | Should -Not -HaveCount 3
        }

        It 'Track should return two similar tracks when id parameter is used' {
            $output = Get-LFMTrackSimilar -Id (New-Guid)
            $output.Track | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMTrackSimilar -Track Track -Artist Artist

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

            { Get-LFMTrackSimilar -Track Track -Artist Artist } | Should -Throw 'Error'
        }
    }
}
