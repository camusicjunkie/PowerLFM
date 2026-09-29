Describe 'Export-LFMScrobbleQueue: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    BeforeEach {
        $queuePath = Join-Path -Path $TestDrive -ChildPath 'nested\ScrobbleQueue.json'
        Remove-Item -LiteralPath (Split-Path -Path $queuePath -Parent) -Recurse -Force -ErrorAction SilentlyContinue

        InModuleScope @module -Parameters @{ QueuePath = $queuePath } {
            param ($QueuePath)
            $script:testQueuePath = $QueuePath
        }
    }

    It 'Creates the queue directory when it does not exist yet' {
        InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Export-LFMScrobbleQueue -Queue ([pscustomobject] @{ Version = 1; Scrobbles = @() })
        }

        Test-Path -LiteralPath $queuePath | Should -BeTrue
    }

    It 'Writes the queue version into the file' {
        InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Export-LFMScrobbleQueue -Queue ([pscustomobject] @{ Version = 1; Scrobbles = @() })
        }

        $written = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
        $written.Version | Should -Be 1
    }

    It 'Round trips the pending scrobbles it was given' {
        InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            $queue = [pscustomobject] @{
                Version   = 1
                Scrobbles = @(
                    [pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 }
                )
            }
            Export-LFMScrobbleQueue -Queue $queue
        }

        $result = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Import-LFMScrobbleQueue
        }

        @($result.Scrobbles).Count | Should -Be 1
        $result.Scrobbles[0].Artist | Should -Be 'Opeth'
        $result.Scrobbles[0].Timestamp | Should -Be 1790596800
    }

    It 'Replaces an existing queue file rather than appending to it' {
        foreach ($count in 1, 2) {
            InModuleScope @module -Parameters @{ Count = $count } {
                param ($Count)
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                $queue = [pscustomobject] @{
                    Version   = 1
                    Scrobbles = @(1..$Count).ForEach({
                        [pscustomobject] @{ Artist = 'Opeth'; Track = "Track $_"; Timestamp = $_ }
                    })
                }
                Export-LFMScrobbleQueue -Queue $queue
            }
        }

        $written = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
        @($written.Scrobbles).Count | Should -Be 2
    }

    It 'Leaves no temporary file behind' {
        InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Export-LFMScrobbleQueue -Queue ([pscustomobject] @{ Version = 1; Scrobbles = @() })
        }

        Test-Path -LiteralPath "$queuePath.tmp" | Should -BeFalse
    }

    It 'Stamps the current version whatever version the caller handed over' {
        InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Export-LFMScrobbleQueue -Queue ([pscustomobject] @{ Version = 99; Scrobbles = @() })
        }

        $written = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
        $written.Version | Should -Be (InModuleScope @module { $scrobbleQueueVersion })
    }

    It 'Writes a queue handed over without a version at all' {
        InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                Scrobbles = @(
                    [pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 }
                )
            })
        }

        $written = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
        $written.Version | Should -Be (InModuleScope @module { $scrobbleQueueVersion })
        @($written.Scrobbles).Count | Should -Be 1
    }
}
