Describe 'Set-LFMTrackLove: Unit' -Tag Unit {

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
            { Set-LFMTrackLove -Artist $null } | Should -Throw
        }

        It 'Should throw when track is null' {
            { Set-LFMTrackLove -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.love as a signed POST' {
            Set-LFMTrackLove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.love'
            $request.HttpMethod | Should -Be 'Post'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
        }

        It 'Sends the artist and track' {
            Set-LFMTrackLove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -Be 'Opeth'
            $request.Parameters['track'] | Should -Be 'Windowpane'
        }

        It 'Sends one request per piped object' {
            @(
                [pscustomobject] @{ Artist = 'Artist1'; Track = 'Track1' }
                [pscustomobject] @{ Artist = 'Artist2'; Track = 'Track2' }
            ) | Set-LFMTrackLove -Confirm:$false

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['track'] | Should -Be 'Track2'
        }

        It 'Sends nothing with -WhatIf' {
            Set-LFMTrackLove -Artist 'Opeth' -Track 'Windowpane' -WhatIf

            Get-LFMRecordedRequest | Should -BeNullOrEmpty
        }
    }

    Context 'Output' {

        It 'Should send proper output when -Whatif is used' {
            $output = Set-LFMTrackLove -Artist Artist -Track Track -Confirm:$false -Verbose 4>&1 | Out-String
            $output | Should -Match 'Performing the operation "Adding love" on target "Track: Track".'
        }

        It 'Never shows the Shared Secret or the Session Key when verbose' {
            $output = Set-LFMTrackLove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false -Verbose *>&1 | Out-String

            $output | Should -Not -Match 'SharedSecretValue'
            $output | Should -Not -Match 'SessionKeyValue'
        }

        It 'Stops at a failed request even when nothing catches it: <Case>' -ForEach @(
            @{ Case = 'no Configuration'; Setup = { $script:LFMConfig = $null } }
            @{
                Case  = 'Last.fm unreachable'
                Setup = {
                    $script:LFMConfig = [pscustomobject] @{ ApiKey = 'k'; SessionKey = 's'; SharedSecret = 'x' }
                    $script:baseUrl = 'http://127.0.0.1:9'
                }
            }
        ) {
            # Pester runs every test inside a try, which stops a function at its first
            # error whatever kind of error it is. A caller with no try is only stopped
            # by an error that ends the script, so this runs where nothing catches.
            $ps = [powershell]::Create()
            try {
                $null = $ps.AddScript({
                    param ($ModulePath, $Setup)
                    Import-Module $ModulePath
                    & (Get-Module PowerLFM) ([scriptblock]::Create($Setup))
                    Set-LFMTrackLove -Artist 'Opeth' -Track 'Windowpane' -Confirm:$false -Verbose
                }).AddArgument((Get-Module PowerLFM).Path).AddArgument($Setup.ToString())
                $null = $ps.Invoke()
            }
            catch {
                # Ending the script surfaces here; the verbose stream is what matters.
            }
            finally {
                $verbose = $ps.Streams.Verbose | Out-String
                $ps.Dispose()
            }

            $verbose | Should -Match 'Adding love'
            $verbose | Should -Not -Match 'has been loved'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-RestMethod { [pscustomobject] @{ error = 6; message = 'Track not found' } } -ModuleName 'PowerLFM'

            { Set-LFMTrackLove -Artist Artist -Track Track -Confirm:$false } | Should -Throw '*Track not found*'
        }
    }
}
