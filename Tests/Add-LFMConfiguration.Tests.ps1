BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Add-LFMConfiguration: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Add-LFMConfiguration'
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
        }

        BeforeAll {
            $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets
        }

        Context 'Parameter [ApiKey] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq ApiKey
            }

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

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq SessionKey
            }

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

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq SharedSecret
            }

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

Describe 'Add-LFMConfiguration: Unit' -Tag Unit {

    BeforeAll {
        Mock Get-Secret -ModuleName 'PowerLFM'
        Mock Set-Secret -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when apiKey is null' {
            { Add-LFMConfiguration -ApiKey $null } | Should -Throw
        }

        It 'Should throw when sessionKey is null' {
            { Add-LFMConfiguration -SessionKey $null } | Should -Throw
        }

        It 'Should throw when sharedSecret is null' {
            { Add-LFMConfiguration -SharedSecret $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            $acParams = @{
                ApiKey       = 'ApiKey'
                SessionKey   = 'SessionKey'
                SharedSecret = 'SharedSecret'
                Confirm      = $false
            }
            Add-LFMConfiguration @acParams
        }

        It 'Should get the configuration for ApiKey' {
            $siParams = @{
                CommandName     = 'Get-Secret'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Name -eq 'LFMApiKey'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should get the configuration for SessionKey' {
            $siParams = @{
                CommandName     = 'Get-Secret'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Name -eq 'LFMSessionKey'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should get the configuration for SharedSecret' {
            $siParams = @{
                CommandName     = 'Get-Secret'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Name -eq 'LFMSharedSecret'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should add the configuration for ApiKey' {
            $siParams = @{
                CommandName     = 'Set-Secret'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Name -eq 'LFMApiKey' -and
                    $Secret -eq 'ApiKey'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should add the configuration for SessionKey' {
            $siParams = @{
                CommandName     = 'Set-Secret'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Name -eq 'LFMSessionKey' -and
                    $Secret -eq 'SessionKey'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should add the configuration for SharedSecret' {
            $siParams = @{
                CommandName     = 'Set-Secret'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Name -eq 'LFMSharedSecret' -and
                    $Secret -eq 'SharedSecret'
                }
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        It 'Should throw when an error is returned in the response' {
            $acParams = @{
                ApiKey       = 'ApiKey'
                SessionKey   = 'SessionKey'
                SharedSecret = 'SharedSecret'
                Confirm      = $false
            }

            Mock Set-Secret { throw 'Error' } -ModuleName 'PowerLFM'

            { Add-LFMConfiguration @acParams } | Should -Throw 'Error'
        }
    }
}
