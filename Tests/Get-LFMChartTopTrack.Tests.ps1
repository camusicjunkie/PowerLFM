Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMChartTopTrack: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMChartTopTrack')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Chart.TopTracks' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Chart.TopTracks'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Limit] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Int32' {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It 'Should have a position of 0' {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Int32' {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
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
    $contextMock = $mocks.'Get-LFMChartTopTrack'.ChartTopTrack

    Describe 'Get-LFMChartTopTrack: Unit' -Tag Unit {

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        }
        Mock ConvertTo-LFMParameter
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri {$contextMock}

        Context 'Input' {

            It 'Should throw when limit is greater than 119' {
                {Get-LFMChartTopTrack -Limit 120} | Should -Throw
            }
        }

        Context 'Execution' {

            Get-LFMChartTopTrack

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

            $output = Get-LFMChartTopTrack

            It "Chart first top track should have track name of $($contextMock.Tracks.Track[0].Name)" {
                $output[0].Track | Should -Be $contextMock.Tracks.Track[0].Name
            }

            It "Chart first top track should have artist name of $($contextMock.Tracks.Track[0].Artist.Name)" {
                $output[0].Artist | Should -Be $contextMock.Tracks.Track[0].Artist.Name
            }

            It "Chart first top track should have duration with a value of $($contextMock.Tracks.Track[0].Duration)" {
                $output[0].Duration | Should -Be $contextMock.Tracks.Track[0].Duration
            }

            It "Chart first top track should have playcount with a value of $($contextMock.Tracks.Track[0].PlayCount)" {
                $output[0].PlayCount | Should -BeOfType [int]
                $output[0].PlayCount | Should -Be $contextMock.Tracks.Track[0].PlayCount
            }

            It "Chart second top track should have playcount with a value of $($contextMock.Tracks.Track[1].PlayCount)" {
                $output[1].PlayCount | Should -BeOfType [int]
                $output[1].PlayCount | Should -Be $contextMock.Tracks.Track[1].PlayCount
            }

            It "Chart second top track should have artist id with a value of $($contextMock.Tracks.Track[1].Artist.Mbid)" {
                $output[1].ArtistId | Should -Be $contextMock.Tracks.Track[1].Artist.Mbid
            }

            It "Chart second top track should have artist url of $($contextMock.Tracks.Track[1].Artist.Url)" {
                $output[1].ArtistUrl | Should -Be $contextMock.Tracks.Track[1].Artist.Url
            }

            It "Chart second top track should have track url of $($contextMock.Tracks.Track[1].Url)" {
                $output[1].TrackUrl | Should -Be $contextMock.Tracks.Track[1].Url
            }

            It 'Chart should have two top tracks' {
                $output.Track | Should -HaveCount 2
            }

            It 'Chart should not have more than two top tracks' {
                $output.Track | Should -Not -BeNullOrEmpty
                $output.Track | Should -Not -HaveCount 3
            }

            It 'Should call the correct Last.fm get method' {
                Get-LFMChartTopTrack

                $amParams = @{
                    CommandName = 'Invoke-LFMApiUri'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                    ParameterFilter = {
                        $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should throw when an error is returned in the response' {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Get-LFMChartTopTrack } | Should -Throw 'Error'
            }
        }
    }
}

Describe 'Get-LFMChartTopTrack: Integration' -Tag Integration {

    It 'Integration test' {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
