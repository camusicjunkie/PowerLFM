Describe 'Scrobble queue: Integration' -Tag Integration {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
        $queuePath = Join-Path -Path $TestDrive -ChildPath 'roundTrip\ScrobbleQueue.json'

        $originalConfig = InModuleScope @module { $script:LFMConfig }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
        }

        # The only seam this stands on: everything below writes, locks, signs and
        # batches for real.
        Mock Get-LFMScrobbleQueuePath { $queuePath } -ModuleName 'PowerLFM'
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    It 'Queues two plays while Last.fm is unreachable, then submits them both' {
        # Offline: a failure with no HTTP response behind it.
        Mock Invoke-RestMethod {
            throw [Net.WebException]::new(
                'The remote name could not be resolved.',
                [Net.WebExceptionStatus]::NameResolutionFailure
            )
        } -ModuleName 'PowerLFM'

        $timestamp = [datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Local)
        Set-LFMTrackScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $timestamp -Album 'Damnation' -WarningAction SilentlyContinue
        Set-LFMTrackScrobble -Artist 'Opeth' -Track 'In My Time Of Need' -Timestamp $timestamp.AddMinutes(8) -WarningAction SilentlyContinue

        # Both plays are on disk, as unix seconds, under a hash of the session key.
        $onDisk = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
        $onDisk.Version | Should -Be 1
        @($onDisk.Scrobbles).Count | Should -Be 2
        $onDisk.Scrobbles[0].Timestamp | Should -Be ([datetimeoffset] $timestamp).ToUnixTimeSeconds()
        $onDisk.Scrobbles[0].SessionKeyFingerprint | Should -Not -Be 'SessionKeyValue'

        # And they read back as pending scrobbles this configuration can submit.
        $pending = Get-LFMScrobbleQueue
        @($pending).Count | Should -Be 2
        $pending[0].Track | Should -Be 'Windowpane'
        $pending[0].Timestamp | Should -Be $timestamp
        $pending[0].MatchesConfiguration | Should -BeTrue

        # Back online: one batched, signed call carrying both plays.
        Mock Invoke-RestMethod {
            [pscustomobject] @{
                Scrobbles = [pscustomobject] @{
                    Scrobble = @(
                        [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } }
                        [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } }
                    )
                }
            }
        } -ModuleName 'PowerLFM'

        Send-LFMScrobbleQueue -Confirm:$false

        $siParams = @{
            CommandName     = 'Invoke-RestMethod'
            ModuleName      = 'PowerLFM'
            Exactly         = $true
            Times           = 1
            Scope           = 'It'
            ParameterFilter = {
                $Method -eq 'Post' -and
                $Uri -match 'artist\[0\]=Opeth' -and
                $Uri -match 'artist\[1\]=Opeth' -and
                $Uri -match 'api_sig=[0-9A-F]{32}'
            }
        }
        Should -Invoke @siParams

        Get-LFMScrobbleQueue | Should -BeNullOrEmpty
        @((Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json).Scrobbles).Count | Should -Be 0
    }
}
