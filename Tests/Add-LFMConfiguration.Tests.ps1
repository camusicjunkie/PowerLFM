BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
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

            Mock Set-Secret { throw 'Error' }

            { Add-LFMConfiguration @acParams } | Should -Throw 'Error'
        }
    }
}
