Describe 'Set-LFMTrackUnlove: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $module = @{ ModuleName = 'PowerLFM' }

        $originalConfig = InModuleScope @module { $script:LFMConfig }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
        }
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    BeforeEach {
        Register-LFMFakeRestMethod
    }

    Context 'Input' {

        It 'Should throw when artist is null' {
            { Set-LFMTrackUnlove -Artist $null } | Should -Throw
        }

        It 'Should throw when track is null' {
            { Set-LFMTrackUnlove -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.unlove as a signed POST' {
            Set-LFMTrackUnlove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.unlove'
            $request.HttpMethod | Should -Be 'Post'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
        }

        It 'Sends the parameters under Last.fm names' {
            Set-LFMTrackUnlove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -BeExactly 'Opeth'
            $request.Parameters['track'] | Should -BeExactly 'Windowpane'
        }

        It 'Sends nothing with -WhatIf' {
            Set-LFMTrackUnlove -Artist 'Opeth' -Track 'Windowpane' -WhatIf

            Get-LFMRecordedRequest | Should -BeNullOrEmpty
        }
    }

    Context 'Output' {

        It 'Should send proper output when -Whatif is used' {
            $output = Set-LFMTrackUnlove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false -Verbose 4>&1 | Out-String
            $output | Should -Match 'Performing the operation "Removing love" on target "Track: Windowpane".'
        }

        It 'Never shows the Shared Secret or the Session Key when verbose' {
            $output = Set-LFMTrackUnlove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false -Verbose *>&1 | Out-String

            $output | Should -Not -Match 'SharedSecretValue'
            $output | Should -Not -Match 'SessionKeyValue'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-RestMethod { [pscustomobject] @{ error = 6; message = 'Not found' } } -ModuleName 'PowerLFM'

            { Set-LFMTrackUnlove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false } | Should -Throw '*Not found*'
        }
    }
}
