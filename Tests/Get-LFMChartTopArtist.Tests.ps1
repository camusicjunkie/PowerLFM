Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMChartTopArtist: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMChartTopArtist')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Chart.TopArtists' {
        $command.OutputType.Name -contains 'PowerLFM.Chart.TopArtists' | Should -BeTrue
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

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
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

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMChartTopArtist'.ChartTopArtist

    Describe 'Get-LFMChartTopArtist: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It 'Should throw when limit is greater than 119' {
                {Get-LFMChartTopArtist -Limit 120} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    set = 'artist'
                    times = 4
                    gctaParams = @{
                        Limit = '5'
                    }
                }
                @{
                    set = 'artist'
                    times = 5
                    gctaParams = @{
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url in <set> parameter set' -TestCases $testCases {
                param ($times, $gctaParams)

                Get-LFMChartTopArtist @gctaParams

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
                $script:output = Get-LFMChartTopArtist
            }

            It 'Should output object of type PowerLFM.Chart.TopArtists' {
                $output[0].PSTypeNames[0] | Should -Be 'PowerLFM.Chart.TopArtists'
            }

            It "Chart first top artist should have name of $($contextMock.artists.artist[0].name)" {
                $output.Artist[0] | Should -Be $contextMock.artists.artist[0].name
            }

            It "Chart first top artist should have id of $($contextMock.artists.artist[0].mbid)" {
                $output.Id[0] | Should -Be $contextMock.artists.artist[0].mbid
            }

            It "Chart first top artist should have listeners with a value of $($contextMock.artists.artist[0].listeners)" {
                $output.Listeners[0] | Should -BeOfType [int]
                $output.Listeners[0] | Should -Be $contextMock.artists.artist[0].listeners
            }

            It "Chart second top artist should have listeners with a value of $($contextMock.artists.artist[1].listeners)" {
                $output.Listeners[1] | Should -BeOfType [int]
                $output.Listeners[1] | Should -Be $contextMock.artists.artist[1].listeners
            }

            It "Chart second top artist should have url of $($contextMock.artists.artist[1].url)" {
                $output.Url[1] | Should -Be $contextMock.artists.artist[1].url
            }

            It "Chart second top artist should have playcount with a value of $($contextMock.artists.artist[1].playcount)" {
                $output.Playcount[1] | Should -BeOfType [int]
                $output.Playcount[1] | Should -Be $contextMock.artists.artist[1].playcount
            }

            It 'Chart should have two top artists' {
                $output.Artist | Should -HaveCount 2
            }

            It 'Chart should not have more than two top artists' {
                $output.Artist | Should -Not -BeNullOrEmpty
                $output.Artist | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMChartTopArtist: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
