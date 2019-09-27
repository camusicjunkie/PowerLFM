Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserTopTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserTopTag')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.TopTag' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.TopTag'
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

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserTopTag'.UserTopTag

    Describe 'Get-LFMUserTopTag: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserTopTag -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 5
                    guttParams = @{
                        UserName = 'UserName'
                        Limit = '5'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $guttParams)

                Get-LFMUserTopTag @guttParams

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
                $script:output = Get-LFMUserTopTag -UserName camusicjunkie
            }

            It "User first top tag should have name of $($contextMock.TopTags.Tag[0].Name)" {
                $output[0].Tag | Should -Be $contextMock.TopTags.Tag[0].Name
            }

            It "User second top tag should have url of $($contextMock.TopTags.Tag[1].Url)" {
                $output[1].TagUrl | Should -Be $contextMock.TopTags.Tag[1].Url
            }

            It "User second top tag should have a count of $($contextMock.TopTags.Tag[1].Count)" {
                $output[1].Count | Should -Be $contextMock.TopTags.Tag[1].Count
            }

            It 'User should have two top tags' {
                $output.Tag | Should -HaveCount 2
            }

            It 'User should not have more than two top tags' {
                $output.Tag | Should -Not -BeNullOrEmpty
                $output.Tag | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserTopTag: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
