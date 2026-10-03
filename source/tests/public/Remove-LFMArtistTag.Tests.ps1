Describe 'Remove-LFMArtistTag: Unit' -Tag Unit {

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

        It 'Should throw when album is null' {
            { Remove-LFMArtistTag -Album $null } | Should -Throw
        }

        It 'Should throw when tag has more than 1 value' {
            { Remove-LFMArtistTag -Artist Artist -Tag @(1..2) } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends artist.removeTag as a signed POST' {
            Remove-LFMArtistTag -Artist 'Opeth' -Tag 'prog' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'artist.removeTag'
            $request.HttpMethod | Should -Be 'Post'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
        }

        It 'Sends the parameters under Last.fm names' {
            Remove-LFMArtistTag -Artist 'Opeth' -Tag 'prog' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -BeExactly 'Opeth'
            $request.Parameters['tag'] | Should -BeExactly 'prog'
        }

        It 'Sends nothing with -WhatIf' {
            Remove-LFMArtistTag -Artist 'Opeth' -Tag 'prog' -WhatIf

            Get-LFMRecordedRequest | Should -BeNullOrEmpty
        }
    }

    Context 'Output' {

        It 'Should send proper output when -Whatif is used' {
            $output = Remove-LFMArtistTag -Artist 'Opeth' -Tag 'prog' -Confirm:$false -Verbose 4>&1 | Out-String
            $output | Should -Match 'Performing the operation "Removing artist tag: prog" on target "Artist: Opeth".'
        }

        It 'Never shows the Shared Secret or the Session Key when verbose' {
            $output = Remove-LFMArtistTag -Artist 'Opeth' -Tag 'prog' -Confirm:$false -Verbose *>&1 | Out-String

            $output | Should -Not -Match 'SharedSecretValue'
            $output | Should -Not -Match 'SessionKeyValue'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-RestMethod { [pscustomobject] @{ error = 6; message = 'Not found' } } -ModuleName 'PowerLFM'

            { Remove-LFMArtistTag -Artist 'Opeth' -Tag 'prog' -Confirm:$false } | Should -Throw '*Not found*'
        }
    }
}
