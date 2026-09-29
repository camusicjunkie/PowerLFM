Describe 'Clear-LFMScrobbleQueue: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    # Driven through a real queue file rather than mocks of the store, because clearing is
    # a Queue Update and what it is worth asserting is what the queue holds afterwards.
    BeforeEach {
        $queuePath = Join-Path -Path $TestDrive -ChildPath 'queue\ScrobbleQueue.json'
        Remove-Item -LiteralPath (Split-Path -Path $queuePath -Parent) -Recurse -Force -ErrorAction SilentlyContinue

        InModuleScope @module -Parameters @{ QueuePath = $queuePath } {
            param ($QueuePath)
            $script:testQueuePath = $QueuePath
        }
    }

    Context 'Execution' {

        It 'Discards every pending scrobble' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Version   = 1
                    Scrobbles = @(
                        [pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 }
                    )
                })

                Clear-LFMScrobbleQueue -Confirm:$false
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 0
        }

        It 'Writes nothing when another session holds the queue' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Version   = 1
                    Scrobbles = @(
                        [pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 }
                    )
                })

                Mock Enter-LFMScrobbleQueueLock { }
                Clear-LFMScrobbleQueue -Confirm:$false -WarningAction SilentlyContinue
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
        }

        It 'Warns that the queue was not cleared when another session holds it' {
            $output = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Version   = 1
                    Scrobbles = @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                })

                Mock Enter-LFMScrobbleQueueLock { }
                Clear-LFMScrobbleQueue -Confirm:$false 3>&1
            }

            $output -join "`n" | Should -Match 'was not cleared'
        }

        It 'Writes nothing when the queue is already empty' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Export-LFMScrobbleQueue

                Clear-LFMScrobbleQueue -Confirm:$false

                Should -Invoke Export-LFMScrobbleQueue -Exactly -Times 0 -Scope It
            }
        }

        It 'Takes no lock when no queue file exists' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Enter-LFMScrobbleQueueLock

                Clear-LFMScrobbleQueue -Confirm:$false

                Should -Invoke Enter-LFMScrobbleQueueLock -Exactly -Times 0 -Scope It
            }
        }
    }

    Context 'Output' {

        It 'Names how many pending scrobbles it is discarding' {
            $output = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Version   = 1
                    Scrobbles = @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                })

                Clear-LFMScrobbleQueue -Confirm:$false -Verbose 4>&1
            }

            $output -join "`n" | Should -Match 'Performing the operation "Discarding" on target "1 pending scrobbles".'
        }

        It 'Says no queue was found rather than that the queue is empty' {
            # The test for a queue file is made before the hold, so the report cannot claim
            # anything about the queue's state: another session can create one immediately
            # after, and the user would have been told there was nothing to discard.
            $output = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }

                Clear-LFMScrobbleQueue -Confirm:$false -Verbose 4>&1
            }

            $output -join "`n" | Should -Match 'No scrobble queue was found'
        }

        It 'Discards nothing when -WhatIf is used' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Version   = 1
                    Scrobbles = @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                })

                Clear-LFMScrobbleQueue -WhatIf
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
        }
    }
}
