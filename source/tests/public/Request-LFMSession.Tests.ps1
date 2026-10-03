Describe 'Request-LFMSession: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Request-LFMSession'.Session

        $module = @{ ModuleName = 'PowerLFM' }

        # The authorization exchange runs before any Configuration exists.
        $originalConfig = InModuleScope @module { $script:LFMConfig }
        InModuleScope @module { $script:LFMConfig = $null }
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
            { Request-LFMSession -ApiKey $null } | Should -Throw
        }

        It 'Should throw when token is null' {
            { Request-LFMSession -Token $null } | Should -Throw
        }

        It 'Should throw when shared secret is null' {
            { Request-LFMSession -SharedSecret $null } | Should -Throw
        }
    }

    Context 'Request' {

        BeforeEach {
            $null = Request-LFMSession -ApiKey 'AppKey' -Token 'TokenValue' -SharedSecret 'AppSecret'
            $request = Get-LFMRecordedRequest
        }

        It 'Sends auth.getSession as a signed GET without a Session Key' {
            $request.Method | Should -Be 'auth.getSession'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the API Key and the Token and never the Shared Secret' {
            $request.Parameters['api_key'] | Should -Be 'AppKey'
            $request.Parameters['token'] | Should -Be 'TokenValue'
            $request.Uri | Should -Not -Match 'AppSecret'
        }
    }

    Context 'Output' {

        It 'Should return the correct session key' {
            $output = Request-LFMSession -ApiKey 'AppKey' -Token 'TokenValue' -SharedSecret 'AppSecret'
            $output.SessionKey | Should -Be $contextMock.Session.Key
        }

        It 'Never shows the Shared Secret when verbose' {
            $output = Request-LFMSession -ApiKey 'AppKey' -Token 'TokenValue' -SharedSecret 'AppSecret' -Verbose 4>&1 |
                Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } | Out-String

            $output | Should -Not -Match 'AppSecret'
        }
    }
}
