BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMConfiguration: Unit' -Tag Unit {

    BeforeAll {
        Mock Get-Secret -ModuleName 'PowerLFM'
    }

    Context 'Execution' {

        It 'Should retrieve the passwords from the SecretStore' {
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
}
