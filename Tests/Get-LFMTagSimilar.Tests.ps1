Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMTagSimilar: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMTagSimilar')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Tag.Similar' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Tag.Similar'
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
    $contextMock = $mocks.'Get-LFMTagSimilar'.TagSimilar

    Describe 'Get-LFMTagSimilar: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It 'Should throw when Tag is null' {
                {Get-LFMTagSimilar -Tag $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gtiParams = @{
                        Tag = 'Tag'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gtiParams)

                Get-LFMTagInfo @gtiParams

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
                $script:output = Get-LFMTagSimilar -Tag Tag
            }

            It "Tag should have name of $($contextMock.Tag.Name)" {
                $output.Tag | Should -Be $contextMock.Tag.Name
            }

            It "Tag should have url of $($contextMock.Tag.Url)" {
                $output.Url | Should -Be $($contextMock.Tag.Url)
            }

            It 'Tag should have one tag' {
                $output.Tag | Should -HaveCount 1
            }

            It 'Tag should not have more than one tag' {
                $output.Tag | Should -Not -BeNullOrEmpty
                $output.Tag | Should -Not -HaveCount 2
            }
        }
    }
}

Describe 'Get-LFMTagSimilar: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
