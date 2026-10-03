Describe 'Request-LFMToken: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Request-LFMToken'.Token

        $module = @{ ModuleName = 'PowerLFM' }

        # The authorization exchange runs before any Configuration exists.
        $originalConfig = InModuleScope @module { $script:LFMConfig }
        InModuleScope @module { $script:LFMConfig = $null }

        Mock Show-LFMAuthWindow -ModuleName 'PowerLFM'
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    BeforeEach {
        Register-LFMFakeRestMethod -Response $contextMock
    }

    Context 'Input' {

        It 'Should throw when api key is null' {
            { Request-LFMToken -ApiKey $null } | Should -Throw
        }

        It 'Should throw when shared secret is null' {
            { Request-LFMToken -SharedSecret $null } | Should -Throw
        }
    }

    Context 'Request' {

        BeforeEach {
            $null = Request-LFMToken -ApiKey 'AppKey' -SharedSecret 'AppSecret'
            $request = Get-LFMRecordedRequest
        }

        It 'Sends auth.getToken as a signed GET without a Session Key' {
            $request.Method | Should -Be 'auth.getToken'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the API Key it was given and never the Shared Secret' {
            $request.Parameters['api_key'] | Should -Be 'AppKey'
            $request.Uri | Should -Not -Match 'AppSecret'
        }
    }

    Context 'Output' {

        It 'Should return the correct token value' {
            $output = Request-LFMToken -ApiKey 'AppKey' -SharedSecret 'AppSecret'
            $output.Token | Should -Be $contextMock.Token
        }

        It 'Never shows the Shared Secret when verbose' {
            $output = Request-LFMToken -ApiKey 'AppKey' -SharedSecret 'AppSecret' -Verbose 4>&1 |
                Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } | Out-String

            $output | Should -Not -Match 'AppSecret'
        }
    }
}
