Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Add-LFMConfiguration: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Add-LFMConfiguration')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
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

        Context 'Parameter [SessionKey] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq SessionKey

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

    Describe 'Add-LFMConfiguration: Unit' -Tag Unit {

        Mock Add-LFMVaultCredential

        Context 'Input' {

            It 'Should throw when apiKey is null' {
                {Add-LFMConfiguration -ApiKey $null} | Should -Throw
            }

            It 'Should throw when sessionKey is null' {
                {Add-LFMConfiguration -SessionKey $null} | Should -Throw
            }

            It 'Should throw when sharedSecret is null' {
                {Add-LFMConfiguration -SharedSecret $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Add-LFMConfiguration -ApiKey ApiKey -SessionKey SessionKey -SharedSecret SharedSecret

            It 'Should add the configuration for ApiKey' {
                $amParams = @{
                    CommandName     = 'Add-LFMVaultCredential'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $UserName -eq 'ApiKey' -and
                        $Pass -eq 'ApiKey'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should add the configuration for SessionKey' {
                $amParams = @{
                    CommandName     = 'Add-LFMVaultCredential'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $UserName -eq 'SessionKey' -and
                        $Pass -eq 'SessionKey'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should add the configuration for SharedSecret' {
                $amParams = @{
                    CommandName     = 'Add-LFMVaultCredential'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $UserName -eq 'SharedSecret' -and
                        $Pass -eq 'SharedSecret'
                    }
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            It 'Should throw when an error is returned in the response' {
                $acParams = @{
                    ApiKey = 'ApiKey'
                    SessionKey = 'SessionKey'
                    SharedSecret = 'SharedSecret'
                }

                Mock Add-LFMVaultCredential { throw 'Error' }

                { Add-LFMConfiguration @acParams } | Should -Throw 'Error'
            }
        }
    }
}
