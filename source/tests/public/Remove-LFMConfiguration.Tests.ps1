# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Remove-LFMConfiguration: Unit' -Tag Unit {

    BeforeAll {
        Mock Get-SecretInfo {
            @{ Name = 'LFMApiKey' },
            @{ Name = 'LFMSessionKey' },
            @{ Name = 'LFMSharedSecret' }
        } -ModuleName 'PowerLFM'
        Mock Remove-Secret -ModuleName 'PowerLFM'
    }

    Context 'Execution' {

        It 'Should remove the passwords from the BuiltInLocalVault' {
            Remove-LFMConfiguration -Confirm:$false

            $siParams = @{
                CommandName = 'Remove-Secret'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 3
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        It 'Should throw when an error is returned in the response' {
            Mock Remove-Secret { throw 'Error' } -ModuleName 'PowerLFM'

            { Remove-LFMConfiguration -Confirm:$false } | Should -Throw 'Error'
        }
    }
}
