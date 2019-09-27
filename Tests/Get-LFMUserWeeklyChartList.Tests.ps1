Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserWeeklyChartList: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserWeeklyChartList')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.WeeklyChartList' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.WeeklyChartList'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [UserName] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName

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

            It 'ValueFromReminingArguments should be set to False' {
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
    $contextMock = $mocks.'Get-LFMUserWeeklyChartList'.UserWeeklyChartList

    Describe 'Get-LFMUserWeeklyChartList: Unit' -Tag Unit {

        Mock Invoke-RestMethod {$contextMock}

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserWeeklyChartList -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    guwclParams = @{
                        UserName = 'UserName'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $guwclParams)

                Get-LFMUserWeeklyChartList @guwclParams

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

            $dateFrom = ConvertFrom-UnixTime -UnixTime 0 -Local
            $dateTo = ConvertFrom-UnixTime -UnixTime 60 -Local
            $output = Get-LFMUserWeeklyChartList -UserName camusicjunkie

            It "User weekly chart first list should have a start date of $dateFrom" {
                $output[1].StartDate | Should -Be $dateFrom
            }

            It "User weekly chart second list should have a start date of $dateTo" {
                $output[0].StartDate | Should -Be $dateTo
            }
        }
    }
}

Describe 'Get-LFMUserWeeklyChartList: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
