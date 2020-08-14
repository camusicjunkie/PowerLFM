BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMConfiguration: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Get-LFMConfiguration'
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

Describe 'Get-LFMConfiguration: Unit' -Tag Unit {

    BeforeAll {
        Mock Get-Secret -ModuleName 'PowerLFM'
    }

    Context 'Execution' {

        It 'Should retrieve the passwords from the BuiltInLocalVault' {
            Get-LFMConfiguration

            $siParams = @{
                CommandName     = 'Get-Secret'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 3
                ParameterFilter = {
                    $Name -eq 'LFMApiKey' -or
                    $Name -eq 'LFMSessionKey' -or
                    $Name -eq 'LFMSharedSecret'
                }
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        It 'Should throw when an error is returned in the response' {
            Mock Get-Secret { throw 'Error' }

            { Get-LFMConfiguration } | Should -Throw 'Error'
        }
    }
}
