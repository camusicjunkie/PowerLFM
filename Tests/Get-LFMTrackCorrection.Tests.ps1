Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMTrackCorrection: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMTrackCorrection')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Track.Correction' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Track.Correction'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Track] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Track

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.String' {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It 'Should have a position of 0' {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [Artist] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Artist

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.String' {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It 'Should have a position of 1' {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMTrackCorrection'.TrackCorrection

    Describe 'Get-LFMTrackCorrection: Unit' -Tag Unit {

        Mock Remove-CommonParameter {
            [hashtable] @{
                Track = 'Track'
                Artist = 'Artist'
            }
        }
        Mock ConvertTo-LFMParameter
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri {$contextMock}

        Context 'Input' {

            It 'Should throw when track is null' {
                {Get-LFMTrackCorrection -Track $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Get-LFMTrackCorrection -Track Track -Artist Artist

            It 'Should remove common parameters from bound parameters' {
                $amParams = @{
                    CommandName     = 'Remove-CommonParameter'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $PSBoundParameters
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should convert parameters to format API expects after signing' {
                $amParams = @{
                    CommandName = 'ConvertTo-LFMParameter'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }

            It 'Should take hashtable and build a query for a uri' {
                $amParams = @{
                    CommandName = 'New-LFMApiQuery'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            $output = Get-LFMTrackCorrection -Track Track -Artist Artist

            It "Corrected track should have a name of $($contextMock.Corrections.Correction.Track.Name)" {
                $output.Track | Should -Be $contextMock.Corrections.Correction.Track.Name
            }

            It "Corrected track should have a url of $($contextMock.Corrections.Correction.Track.Url)" {
                $output.TrackUrl | Should -Be $contextMock.Corrections.Correction.Track.Url
            }

            It "Corrected track should have an artist name of $($contextMock.Corrections.Correction.Track.Artist.Name)" {
                $output.Artist | Should -Be $contextMock.Corrections.Correction.Track.Artist.Name
            }

            It "Corrected track should have an artist id of $($contextMock.Corrections.Correction.Track.Artist.Mbid)" {
                $output.ArtistId | Should -Be $contextMock.Corrections.Correction.Track.Artist.Mbid
            }

            It "Corrected track should have an artist url of $($contextMock.Corrections.Correction.Track.Artist.Url)" {
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
                $amParams = @{
                    CommandName = 'Invoke-LFMApiUri'
                    Exactly = $true
                    Times = 1
                    Scope = 'Context'
                    ParameterFilter = {
                        $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should throw when an error is returned in the response' {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Get-LFMTrackCorrection -Track Track -Artist Artist } | Should -Throw 'Error'
            }
        }
    }
}
