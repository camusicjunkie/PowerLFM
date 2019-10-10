Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMTagWeeklyChartList: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMTagWeeklyChartList')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Tag.WeeklyChartList' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Tag.WeeklyChartList'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Tag] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Tag

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
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

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMTagWeeklyChartList'.TagWeeklyChartList

    Describe 'Get-LFMTagWeeklyChartList: Unit' -Tag Unit {

        Mock Invoke-RestMethod {$contextMock}

        Context 'Input' {

            It "Should throw when Tag is null" {
                {Get-LFMTagWeeklyChartList -Tag $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gtwcParams = @{
                        Tag = 'Tag'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gtwcParams)

                Get-LFMTagWeeklyChartList -Tag Tag

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

            BeforeEach {
                $script:output = Get-LFMTagWeeklyChartList -Tag Tag
            }

            Mock ConvertFrom-UnixTime {$mocks.UnixTime.From}

            It "Tag first weekly chart list should have start date of $($mocks.UnixTime.From)" {
                $output[0].StartDate | Should -Be $mocks.UnixTime.From
            }

            Mock ConvertFrom-UnixTime {$mocks.UnixTime.To}

            It "Tag second weekly chart list should have end date of $($mocks.UnixTime.To)" {
                $output[0].EndDate | Should -Be $mocks.UnixTime.To
            }

            It 'Tag should have two charts' {
                $output.StartDate | Should -HaveCount 2
            }

            It 'Tag should not have more than two charts' {
                $output.StartDate | Should -Not -BeNullOrEmpty
                $output.StartDate | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMTagWeeklyChartList: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
