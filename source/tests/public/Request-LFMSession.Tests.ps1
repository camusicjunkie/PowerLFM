# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Request-LFMSession: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Request-LFMSession'.Session
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Request-LFMSession'.Session

        Mock Remove-CommonParameter {
            [hashtable] @{
                ApiKey       = 'ApiKey'
                Token        = 'Token'
                SharedSecret = 'SharedSecret'
            }
        } -ModuleName 'PowerLFM'
        Mock Get-LFMSignature -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when api key is null' {
            { Request-LFMSession -ApiKey $null } | Should -Throw
        }

        It 'Should throw when token is null' {
            { Request-LFMSession -Token $null } | Should -Throw
        }

        It 'Should throw when shared secret is null' {
            { Request-LFMSession -SharedSecret $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Request-LFMSession -ApiKey 'ApiKey' -Token 'Token' -SharedSecret 'SharedSecret'
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
                    $Token -eq 'Token' -and
                    $SharedSecret -eq 'SharedSecret' -and
                    $Method -eq 'auth.getSession'
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
            $output = Request-LFMSession -ApiKey 'ApiKey' -Token 'Token' -SharedSecret 'SharedSecret'
        }

        It "Session key should have a value of $($contextMock.Session.Key)" {
            $output.SessionKey | Should -Be $contextMock.Session.Key
        }
    }
}
