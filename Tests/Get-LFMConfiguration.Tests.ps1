Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMConfiguration: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMConfiguration')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
        }
    }
}

InModuleScope PowerLFM {

    Describe 'Get-LFMConfiguration: Unit' -Tag Unit {

        Mock Get-VaultPassword

        Context 'Execution' {

            It 'Should retrieve the password from the Windows Credential Manager' {
                Get-LFMConfiguration

                $amParams = @{
                    CommandName = 'Get-VaultPassword'
                    Exactly = $true
                    Times = 3
                    Scope = 'It'
                    ParameterFilter = {
                        $Resource -eq 'PowerLFM' -and
                        $Name -eq 'ApiKey' -or
                        $Name -eq 'SessionKey' -or
                        $Name -eq 'SharedSecret'
                    }
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            It 'Should throw when an error is returned in the response' {
                Mock Get-VaultPassword { throw 'Error' }

                { Get-LFMConfiguration } | Should -Throw 'Error'
            }
        }
    }
}
