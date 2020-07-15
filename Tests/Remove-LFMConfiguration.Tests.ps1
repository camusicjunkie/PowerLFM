Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Remove-LFMConfiguration: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Remove-LFMConfiguration')
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

    Describe 'Remove-LFMConfiguration: Unit' -Tag Unit {

        Mock Get-SecretInfo {
            @{ Name = 'LFMApiKey' },
            @{ Name = 'LFMSessionKey' },
            @{ Name = 'LFMSharedSecret' }
        }
        Mock Remove-Secret

        Context 'Execution' {

            It 'Should remove the passwords from the BuiltInLocalVault' {
                Remove-LFMConfiguration -Confirm:$false

                $amParams = @{
                    CommandName = 'Remove-Secret'
                    Exactly = $true
                    Times = 3
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            It 'Should throw when an error is returned in the response' {
                Mock Remove-Secret { throw 'Error' }

                { Remove-LFMConfiguration -Confirm:$false } | Should -Throw 'Error'
            }
        }
    }
}
