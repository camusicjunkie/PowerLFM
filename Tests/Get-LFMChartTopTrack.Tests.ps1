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

            It "Should be of type System.Int32" {
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

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Int32" {
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

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMChartTopTrack'.ChartTopTrack

    Describe 'Get-LFMChartTopTrack: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when limit is greater than 119" {
                {Get-LFMChartTopTrack -Limit 120} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gcttParams = @{
                        Limit = '5'
                    }
                }
                @{
                    times = 5
                    gcttParams = @{
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gcttParams)

                Get-LFMChartTopTrack @gcttParams

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
                $script:output = Get-LFMChartTopTrack
            }

            It "Chart first top track should have track name of $($contextMock.Tracks.Track[0].Name)" {
                $output[0].Track | Should -Be $contextMock.Tracks.Track[0].Name
            }

            It "Chart first top track should have artist name of $($contextMock.Tracks.Track[0].Artist.Name)" {
                $output[0].Artist | Should -Be $contextMock.Tracks.Track[0].Artist.Name
            }

            It "Chart first top track should have duration with a value of $($contextMock.Tracks.Track[0].Duration)" {
                $output[0].Duration | Should -Be $contextMock.Tracks.Track[0].Duration
            }

            It "Chart first top track should have playcount with a value of $($contextMock.Tracks.Track[0].Playcount)" {
                $output[0].Playcount | Should -BeOfType [int]
                $output[0].Playcount | Should -Be $contextMock.Tracks.Track[0].Playcount
            }

            It "Chart second top track should have playcount with a value of $($contextMock.Tracks.Track[1].Playcount)" {
                $output[1].Playcount | Should -BeOfType [int]
                $output[1].Playcount | Should -Be $contextMock.Tracks.Track[1].Playcount
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
        }
    }
}

Describe 'Get-LFMChartTopTrack: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
