Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Request-LFMSession: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Request-LFMSession')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of System.String' {
        $command.OutputType.Name | Should -Be 'System.String'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [ApiKey] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq ApiKey

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

        Context 'Parameter [Token] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Token

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

        Context 'Parameter [SharedSecret] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq SharedSecret

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

            It 'Should have a position of 2' {
                $parameter.Position | Should -Be 2
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Request-LFMSession'.Session

    Describe 'Request-LFMSession: Unit' -Tag Unit {

        Mock Invoke-RestMethod
        Mock Get-LFMAuthSignature

        Context 'Input' {

            It 'Should throw when api key is null' {
                {Request-LFMSession -ApiKey $null} | Should -Throw
            }

            It 'Should throw when token is null' {
                {Request-LFMSession -Token $null} | Should -Throw
            }

            It 'Should throw when shared secret is null' {
                {Request-LFMSession -SharedSecret $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 5
                    rsParams = @{
                        ApiKey = 'ApiKey'
                        Token = 'Token'
                        SharedSecret = 'SharedSecret'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $rsParams)

                Request-LFMSession @rsParams

                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = $times
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }

            It 'Should create a signature' {
                $amParams = @{
                    CommandName = 'Get-LFMAuthSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $ApiKey -eq 'ApiKey' -and
                        $Token -eq 'Token' -and
                        $SharedSecret -eq 'SharedSecret' -and
                        $Method -eq 'auth.getSession'
                    }
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            Mock Invoke-RestMethod {$contextMock}

            BeforeEach {
                $script:output = Request-LFMSession -ApiKey 'ApiKey' -Token 'Token' -SharedSecret 'SharedSecret'
            }

            It "Session key should have a value of $($contextMock.Session.Key)" {
                $output.SessionKey | Should -Be $contextMock.Session.Key
            }
        }
    }
}

Describe 'Request-LFMSession: Integration' -Tag Integration {

    It 'Integration test' {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
