Describe 'Add-LFMAlbumTag: Unit' -Tag Unit {

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
            { Add-LFMAlbumTag -Album $null } | Should -Throw
        }

        It 'Should throw when tag has more than 10 values' {
            { Add-LFMAlbumTag -Album Album -Artist Artist -Tag @(1..11) -Confirm:$false } | Should -Throw
        }

        It 'Should not throw when tag has 1 to 10 values' {
            { Add-LFMAlbumTag -Album Album -Artist Artist -Tag @(1..10) -Confirm:$false } | Should -Not -Throw
        }

        It 'Should not throw when multiple objects are piped' {
            $albums = @(
                [pscustomobject] @{ Album = 'Album1'; Artist = 'Artist1'; Tag = 'Tag' }
                [pscustomobject] @{ Album = 'Album2'; Artist = 'Artist2'; Tag = 'Tag' }
            )
            { $albums | Add-LFMAlbumTag -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends album.addTags as a signed POST' {
            Add-LFMAlbumTag -Album 'Damnation' -Artist 'Opeth' -Tag 'prog' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'album.addTags'
            $request.HttpMethod | Should -Be 'Post'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
        }

        It 'Sends the parameters under Last.fm names' {
            Add-LFMAlbumTag -Album 'Damnation' -Artist 'Opeth' -Tag 'prog' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Parameters['album'] | Should -BeExactly 'Damnation'
            $request.Parameters['artist'] | Should -BeExactly 'Opeth'
            $request.Parameters['tags'] | Should -BeExactly 'prog'
        }

        It 'Sends several tags comma-joined' {
            Add-LFMAlbumTag -Album 'Damnation' -Artist 'Opeth' -Tag 'rock', 'indie' -Confirm:$false

            (Get-LFMRecordedRequest).Parameters['tags'] | Should -BeExactly 'rock,indie'
        }

        It 'Sends nothing with -WhatIf' {
            Add-LFMAlbumTag -Album 'Damnation' -Artist 'Opeth' -Tag 'prog' -WhatIf

            Get-LFMRecordedRequest | Should -BeNullOrEmpty
        }
    }

    Context 'Output' {

        It 'Should send proper output when -Whatif is used' {
            $output = Add-LFMAlbumTag -Album 'Damnation' -Artist 'Opeth' -Tag 'prog' -Confirm:$false -Verbose 4>&1 | Out-String
            $output | Should -Match 'Performing the operation "Adding album tag: prog" on target "Album: Damnation".'
        }

        It 'Never shows the Shared Secret or the Session Key when verbose' {
            $output = Add-LFMAlbumTag -Album 'Damnation' -Artist 'Opeth' -Tag 'prog' -Confirm:$false -Verbose *>&1 | Out-String

            $output | Should -Not -Match 'SharedSecretValue'
            $output | Should -Not -Match 'SessionKeyValue'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-RestMethod { [pscustomobject] @{ error = 6; message = 'Not found' } } -ModuleName 'PowerLFM'

            { Add-LFMAlbumTag -Album 'Damnation' -Artist 'Opeth' -Tag 'prog' -Confirm:$false } | Should -Throw '*Not found*'
        }
    }
}
