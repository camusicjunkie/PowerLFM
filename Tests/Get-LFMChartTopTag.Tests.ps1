Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMChartTopTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMChartTopTag')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Chart.TopTags' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Chart.TopTags'
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
    $contextMock = $mocks.'Get-LFMChartTopTag'.ChartTopTag

    Describe 'Get-LFMChartTopTag: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It 'Should throw when limit is greater than 119' {
                {Get-LFMChartTopTag -Limit 120} | Should -Throw
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

                Get-LFMChartTopTag @gcttParams

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
                $script:output = Get-LFMChartTopTag
            }

            It "Chart first top tag should have name of $($contextMock.Tags.Tag[0].Name)" {
                $output[0].Tag | Should -Be $contextMock.Tags.Tag[0].Name
            }

            It "Chart first top tag should have total tags with a value of $($contextMock.Tags.Tag[0].Taggings)" {
                $output[0].TotalTags | Should -Be $contextMock.Tags.Tag[0].Taggings
            }

            It "Chart first top tag should have reach with a value of $($contextMock.Tags.Tag[0].reach)" {
                $output[0].Reach | Should -BeOfType [int]
                $output[0].Reach | Should -Be $contextMock.Tags.Tag[0].reach
            }

            It "Chart second top tag should have reach with a value of $($contextMock.Tags.Tag[1].reach)" {
                $output[1].Reach | Should -BeOfType [int]
                $output[1].Reach | Should -Be $contextMock.Tags.Tag[1].reach
            }

            It "Chart second top tag should have url of $($contextMock.Tags.Tag[1].Url)" {
                $output[1].Url | Should -Be $contextMock.Tags.Tag[1].Url
            }

            It 'Chart should have two top tags' {
                $output.Tag | Should -HaveCount 2
            }

            It 'Chart should not have more than two top tags' {
                $output.Tag | Should -Not -BeNullOrEmpty
                $output.Tag | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMChartTopTag: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
