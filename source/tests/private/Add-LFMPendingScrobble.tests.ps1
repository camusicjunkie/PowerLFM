Describe 'Add-LFMPendingScrobble: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
        $timestamp = [datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Utc)
        $unixTimestamp = ([datetimeoffset] $timestamp).ToUnixTimeSeconds()
    }

    BeforeEach {
        $queuePath = Join-Path -Path $TestDrive -ChildPath 'queue\ScrobbleQueue.json'
        Remove-Item -LiteralPath (Split-Path -Path $queuePath -Parent) -Recurse -Force -ErrorAction SilentlyContinue

        InModuleScope @module -Parameters @{ QueuePath = $queuePath } {
            param ($QueuePath)
            $script:testQueuePath = $QueuePath
        }
    }

    Context 'Appending' {

        It 'Writes the pending scrobble to the queue' {
            InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
            $queue.Scrobbles[0].Artist | Should -Be 'Opeth'
            $queue.Scrobbles[0].Track | Should -Be 'Windowpane'
        }

        It 'Stores the timestamp as a unix integer in UTC' {
            InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            $queue.Scrobbles[0].Timestamp | Should -Be $unixTimestamp
        }

        It 'Stamps the pending scrobble with the session key fingerprint' {
            InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            $queue.Scrobbles[0].SessionKeyFingerprint | Should -Be 'FINGERPRINT'
        }

        It 'Keeps the optional details it was given' {
            InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $apParams = @{
                    Artist      = 'Opeth'
                    Track       = 'Windowpane'
                    Timestamp   = $Timestamp
                    Album       = 'Damnation'
                    TrackNumber = 1
                    Duration    = 469
                }
                $null = Add-LFMPendingScrobble @apParams -WarningAction SilentlyContinue
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            $queue.Scrobbles[0].Album | Should -Be 'Damnation'
            $queue.Scrobbles[0].TrackNumber | Should -Be 1
            $queue.Scrobbles[0].Duration | Should -Be 469
        }

        It 'Appends to the pending scrobbles already queued' {
            InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'In My Time Of Need' -Timestamp $Timestamp.AddMinutes(8) -WarningAction SilentlyContinue
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 2
        }

        It 'Does not queue the same artist, track and timestamp twice' {
            InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
        }

        It 'Says it queued nothing when the scrobble was queued already' {
            $warnings = InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningVariable queueWarnings -WarningAction SilentlyContinue
                $queueWarnings
            }

            $warnings.Message -join "`n" | Should -Match 'is already in the scrobble queue'
        }
    }

    Context 'Output' {

        It 'Outputs the pending scrobble it queued' {
            $result = InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningAction SilentlyContinue
            }

            $result.PSTypeNames | Should -Contain 'PowerLFM.Track.PendingScrobble'
            $result.Artist | Should -Be 'Opeth'
            $result.MatchesConfiguration | Should -BeTrue
        }

        It 'Warns that the scrobble was queued rather than recorded' {
            $warnings = InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningVariable queueWarnings -WarningAction SilentlyContinue
                $queueWarnings
            }

            $warnings.Message | Should -Match 'Windowpane'
        }

        It 'Warns when the queue has grown past a thousand pending scrobbles' {
            $warnings = InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }

                $queue = [pscustomobject] @{
                    Version   = $scrobbleQueueVersion
                    Scrobbles = @(1..1000).ForEach({
                        [pscustomobject] @{
                            Artist                = 'Opeth'
                            Track                 = "Track $_"
                            Timestamp             = $_
                            SessionKeyFingerprint = 'FINGERPRINT'
                        }
                    })
                }
                Export-LFMScrobbleQueue -Queue $queue

                $null = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningVariable queueWarnings -WarningAction SilentlyContinue
                $queueWarnings
            }

            $warnings.Message -join "`n" | Should -Match '1001 pending scrobbles'
        }
    }

    Context 'Failure' {

        It 'Queues nothing and warns when another session holds the queue' {
            $warnings = InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                Mock Enter-LFMScrobbleQueueLock { }

                $result = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningVariable queueWarnings -WarningAction SilentlyContinue
                $result | Should -BeNullOrEmpty
                $queueWarnings
            }

            $warnings.Message | Should -Match 'in use by another session'
            Test-Path -LiteralPath $queuePath | Should -BeFalse
        }

        It 'Queues nothing and warns when no configuration is loaded' {
            $warnings = InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { throw 'No configuration is loaded.' }

                $result = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningVariable queueWarnings -WarningAction SilentlyContinue
                $result | Should -BeNullOrEmpty
                $queueWarnings
            }

            $warnings.Message | Should -Match 'could not be queued'
        }

        It 'Queues nothing and warns when the queue file cannot be read' {
            $warnings = InModuleScope @module -Parameters @{ Timestamp = $timestamp } {
                param ($Timestamp)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' }
                Mock Import-LFMScrobbleQueue { throw 'The scrobble queue has an unrecognised version.' }

                $result = Add-LFMPendingScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $Timestamp -WarningVariable queueWarnings -WarningAction SilentlyContinue
                $result | Should -BeNullOrEmpty
                $queueWarnings
            }

            $warnings.Message | Should -Match 'unrecognised version'
        }
    }
}
