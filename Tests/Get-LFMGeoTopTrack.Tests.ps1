Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMGeoTopTrack: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMGeoTopTrack')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Geo.TopTracks' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Geo.TopTracks'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Country] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Country

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
            }

            It 'ValueFromPipeline should be set to True' {
                $parameter.ValueFromPipeline | Should -BeTrue
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [City] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq City

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 3" {
                $parameter.Position | Should -Be 3
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMGeoTopTrack'.GeoTopTrack

    Describe 'Get-LFMGeoTopTrack: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when limit is greater than 119" {
                {Get-LFMGeoTopTrack -Country Country -Limit 120} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    ggttParams = @{
                        Country = 'Country'
                    }
                }
                @{
                    times = 5
                    ggttParams = @{
                        Country = 'Country'
                        City = 'City'
                    }
                }
                @{
                    times = 6
                    ggttParams = @{
                        Country = 'Country'
                        City = 'City'
                        Limit = '5'
                    }
                }
                @{
                    times = 7
                    ggttParams = @{
                        Country = 'Country'
                        City = 'City'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $ggttParams)

                Get-LFMGeoTopTrack @ggttParams

                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = $times
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            Mock Invoke-RestMethod {$contextMock}

            BeforeEach {
                $script:output = Get-LFMGeoTopTrack -Country Country
            }

            It "Country first top track should have track name of $($contextMock.tracks.track[0].name)" {
                $output.Track[0] | Should -Be $contextMock.tracks.track[0].name
            }

            It "Country first top track should have artist name of $($contextMock.tracks.track[0].artist.name)" {
                $output.Artist[0] | Should -Be $contextMock.tracks.track[0].artist.name
            }

            It "Country first top track should have track id with a value of $($contextMock.tracks.track[0].mbid)" {
                $output.TrackId[0] | Should -Be $contextMock.tracks.track[0].mbid
            }

            It "Country first top track should have listeners with a value of $($contextMock.tracks.track[0].Listeners)" {
                $output.Listeners[0] | Should -BeOfType [int]
                $output.Listeners[0] | Should -Be $contextMock.tracks.track[0].Listeners
            }

            It "Country second top track should have listeners with a value of $($contextMock.tracks.track[1].Listeners)" {
                $output.Listeners[1] | Should -BeOfType [int]
                $output.Listeners[1] | Should -Be $contextMock.tracks.track[1].Listeners
            }

            It "Country second top track should have artist id with a value of $($contextMock.tracks.track[1].artist.mbid)" {
                $output.ArtistId[1] | Should -Be $contextMock.tracks.track[1].artist.mbid
            }

            It "Country second top track should have artist url of $($contextMock.tracks.track[1].artist.url)" {
                $output.ArtistUrl[1] | Should -Be $contextMock.tracks.track[1].artist.url
            }

            It "Country second top track should have track url of $($contextMock.tracks.track[1].url)" {
                $output.TrackUrl[1] | Should -Be $contextMock.tracks.track[1].url
            }

            It 'Country should have two top tracks' {
                $output.Track | Should -HaveCount 2
            }

            It 'Country should not have more than two top tracks' {
                $output.Track | Should -Not -BeNullOrEmpty
                $output.Track | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMGeoTopTrack: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
