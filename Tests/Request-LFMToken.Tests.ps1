BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Request-LFMToken: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Request-LFMToken'.Token
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Request-LFMToken'.Token

        Mock Remove-CommonParameter {
            [hashtable] @{
                ApiKey       = 'ApiKey'
                SharedSecret = 'SharedSecret'
            }
        } -ModuleName 'PowerLFM'
        Mock Get-LFMSignature -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Show-LFMAuthWindow -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when api key is null' {
            { Request-LFMToken -ApiKey $null } | Should -Throw
        }

        It 'Should throw when shared secret is null' {
            { Request-LFMToken -SharedSecret $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Request-LFMToken -ApiKey 'ApiKey' -SharedSecret 'SharedSecret'
        }

        It 'Should remove common parameters from bound parameters' {
            $siParams = @{
                CommandName     = 'Remove-CommonParameter'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $PSBoundParameters
                }
            }
            Should -Invoke @siParams
        }

        It 'Should create a signature' {
            $siParams = @{
                CommandName     = 'Get-LFMSignature'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $ApiKey -eq 'ApiKey' -and
                    $SharedSecret -eq 'SharedSecret' -and
                    $Method -eq 'auth.getToken'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should take hashtable and build a query for a uri' {
            $siParams = @{
                CommandName = 'New-LFMApiQuery'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        BeforeAll {
            $output = Request-LFMToken -ApiKey 'ApiKey' -SharedSecret 'SharedSecret'
        }

        It "Token key should have a value of $($contextMock.Token)" {
            $output.Token | Should -Be $contextMock.Token
        }
    }
}
