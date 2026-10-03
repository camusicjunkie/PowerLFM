Describe 'Send-LFMScrobbleBatch: Unit' -Tag Unit {

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

        $twoScrobbles = @(
            [pscustomobject] @{
                Artist      = 'Opeth'
                Album       = 'Damnation'
                Track       = 'Windowpane'
                Timestamp   = 1790596800
                TrackNumber = 1
                Duration    = 469
                Id          = $null
            }
            [pscustomobject] @{
                Artist      = 'Katatonia'
                Album       = $null
                Track       = 'Ghost Of The Sun'
                Timestamp   = 1790597100
                TrackNumber = $null
                Duration    = $null
                Id          = $null
            }
        )
    }

    BeforeEach {
        Register-LFMFakeRestMethod
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    Context 'Request' {

        It 'Numbers every scrobble in the batch' {
            InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }
            $request = Get-LFMRecordedRequest

            $request.Parameters['artist[0]'] | Should -Be 'Opeth'
            $request.Parameters['track[0]'] | Should -Be 'Windowpane'
            $request.Parameters['timestamp[0]'] | Should -Be '1790596800'
            $request.Parameters['artist[1]'] | Should -Be 'Katatonia'
            $request.Parameters['timestamp[1]'] | Should -Be '1790597100'
        }

        It 'Sends the optional details only for the scrobbles that have them' {
            InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }
            $request = Get-LFMRecordedRequest

            $request.Parameters['album[0]'] | Should -Be 'Damnation'
            $request.Parameters['trackNumber[0]'] | Should -Be '1'
            $request.Parameters['duration[0]'] | Should -Be '469'
            $request.Parameters.Keys | Should -Not -Contain 'album[1]'
            $request.Parameters.Keys | Should -Not -Contain 'trackNumber[1]'
            $request.Parameters.Keys | Should -Not -Contain 'duration[1]'
            $request.Parameters.Keys | Should -Not -Contain 'mbid[0]'
        }

        It 'Signs the batch' {
            InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }
            $request = Get-LFMRecordedRequest

            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
        }

        It 'Never puts the shared secret on the wire' {
            InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }
            $request = Get-LFMRecordedRequest

            $request.Uri | Should -Not -Match 'SharedSecretValue'
        }

        It 'Calls the scrobble method over POST' {
            InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }
            $request = Get-LFMRecordedRequest

            @($request).Count | Should -Be 1
            $request.Method | Should -Be 'track.scrobble'
            $request.HttpMethod | Should -Be 'Post'
        }

        It 'Never shows the Shared Secret or the Session Key when verbose' {
            $streams = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Send-LFMScrobbleBatch -Scrobble $Scrobbles -Verbose *>&1
            }
            $verbose = @($streams | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] })

            $verbose.Count | Should -Be 1
            $verbose[0].Message | Should -Match 'track\.scrobble POST'
            ($streams | Out-String) | Should -Not -Match 'SharedSecretValue'
            ($streams | Out-String) | Should -Not -Match 'SessionKeyValue'
        }
    }

    Context 'Output' {

        It 'Outputs one result per submitted scrobble' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{
                Scrobbles = [pscustomobject] @{
                    Scrobble = @(
                        [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } }
                        [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 3 } }
                    )
                }
            })

            $results = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }

            @($results).Count | Should -Be 2
            $results[1].IgnoredMessage.Code | Should -Be 3
        }

        It 'Outputs a single result as a collection' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{
                Scrobbles = [pscustomobject] @{
                    Scrobble = [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } }
                }
            })

            $results = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }

            @($results).Count | Should -Be 1
        }
    }
}
