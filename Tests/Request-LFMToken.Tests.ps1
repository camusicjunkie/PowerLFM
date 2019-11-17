Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Request-LFMToken: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Request-LFMToken')
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
    $contextMock = $mocks.'Request-LFMToken'.Token

    Describe 'Request-LFMToken: Unit' -Tag Unit {

        Mock Remove-CommonParameter {
            [hashtable] @{
                ApiKey = 'ApiKey'
                SharedSecret = 'SharedSecret'
            }
        }
        Mock Get-LFMSignature
        Mock New-LFMApiQuery
        Mock Show-LFMAuthWindow
        Mock Invoke-LFMApiUri {$contextMock}

        Context 'Input' {

            It 'Should throw when api key is null' {
                {Request-LFMToken -ApiKey $null} | Should -Throw
            }

            It 'Should throw when shared secret is null' {
                {Request-LFMToken -SharedSecret $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Request-LFMToken -ApiKey 'ApiKey' -SharedSecret 'SharedSecret'

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

            It 'Should create a signature' {
                $amParams = @{
                    CommandName = 'Get-LFMSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $ApiKey -eq 'ApiKey' -and
                        $SharedSecret -eq 'SharedSecret' -and
                        $Method -eq 'auth.getToken'
                    }
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

            $output = Request-LFMToken -ApiKey 'ApiKey' -SharedSecret 'SharedSecret'

            It "Token key should have a value of $($contextMock.Token)" {
                $output.Token | Should -Be $contextMock.Token
            }
        }
    }
}

Describe 'Request-LFMToken: Integration' -Tag Integration {

    It 'Integration test' {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
