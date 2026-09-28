Describe 'Update-LFMScrobbleQueue: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    BeforeEach {
        $queuePath = Join-Path -Path $TestDrive -ChildPath 'queue\ScrobbleQueue.json'
        Remove-Item -LiteralPath (Split-Path -Path $queuePath -Parent) -Recurse -Force -ErrorAction SilentlyContinue

        InModuleScope @module -Parameters @{ QueuePath = $queuePath } {
            param ($QueuePath)
            $script:testQueuePath = $QueuePath
        }
    }

    Context 'The change' {

        It 'Hands the change the pending scrobbles already queued' {
            $seen = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Version   = 1
                    Scrobbles = @(
                        [pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 }
                        [pscustomobject] @{ Artist = 'Tool'; Track = 'Lateralus'; Timestamp = 1790596801 }
                    )
                })

                $collected = [Collections.Generic.List[object]]::new()
                $null = Update-LFMScrobbleQueue -Change {
                    param ($Scrobbles, $Save)
                    $Scrobbles.ForEach({ $collected.Add($_.Artist) })
                }
                $collected
            }

            $seen | Should -Be @('Opeth', 'Tool')
        }

        It 'Hands the change an empty set rather than nothing when the queue is empty' {
            $count = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }

                $collected = [Collections.Generic.List[object]]::new()
                $null = Update-LFMScrobbleQueue -Change {
                    param ($Scrobbles, $Save)
                    $collected.Add(@($Scrobbles).Count)
                }
                $collected[0]
            }

            $count | Should -Be 0
        }

        It 'Says it updated the queue when the change ran' {
            $result = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) }
            }

            $result | Should -Be 'Updated'
        }

        It 'Discards whatever the change emits' {
            $result = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) 'noise'; 'more noise' }
            }

            $result | Should -Be 'Updated'
        }
    }

    Context 'Committing' {

        It 'Writes what the change commits' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                $null = Update-LFMScrobbleQueue -Change {
                    param ($Scrobbles, $Save)
                    & $Save @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                }
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
            $queue.Scrobbles[0].Artist | Should -Be 'Opeth'
        }

        It 'Stamps the current queue version without the change supplying one' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                $null = Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) & $Save @() }
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            $queue.Version | Should -Be 1
        }

        It 'Leaves the queue untouched when the change never commits' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Version   = 1
                    Scrobbles = @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                })

                $null = Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) }
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
        }

        It 'Creates no queue file when the change never commits' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                $null = Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) }
            }

            Test-Path -LiteralPath $queuePath | Should -BeFalse
        }

        It 'Keeps the last of several commits' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                $null = Update-LFMScrobbleQueue -Change {
                    param ($Scrobbles, $Save)
                    & $Save @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                    & $Save @([pscustomobject] @{ Artist = 'Tool'; Track = 'Lateralus'; Timestamp = 1790596801 })
                }
            }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
            $queue.Scrobbles[0].Artist | Should -Be 'Tool'
        }
    }

    Context 'Failure' {

        It 'Lets the change throw out to its caller' {
            {
                InModuleScope @module {
                    Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                    $null = Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) throw 'no' }
                }
            } | Should -Throw
        }

        # What a Flush relies on: a process that dies part way through must not resubmit
        # plays Last.fm has already accounted for.
        It 'Leaves a commit made before the change threw' {
            try {
                InModuleScope @module {
                    Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                    $null = Update-LFMScrobbleQueue -Change {
                        param ($Scrobbles, $Save)
                        & $Save @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                        throw 'no'
                    }
                }
            }
            catch { }

            $queue = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
            @($queue.Scrobbles).Count | Should -Be 1
        }

        It 'Releases the lock even when the change throws' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                try {
                    $null = Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) throw 'no' }
                }
                catch { }

                # Nothing is returned when the lock is still held elsewhere.
                Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) } | Should -Be 'Updated'
            }
        }
    }

    Context 'Contention' {

        It 'Says the queue is contended when another session holds it' {
            $result = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Enter-LFMScrobbleQueueLock { }
                Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) & $Save @() }
            }

            $result | Should -Be 'Contended'
        }

        It 'Runs no change when another session holds the queue' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Enter-LFMScrobbleQueueLock { }
                Mock Export-LFMScrobbleQueue

                $null = Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) & $Save @() }

                Should -Invoke Export-LFMScrobbleQueue -Exactly -Times 0 -Scope It
            }
        }
    }

    Context 'An absent queue' {

        It 'Says the queue is absent when -SkipIfAbsent was given and there is no file' {
            $result = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Update-LFMScrobbleQueue -SkipIfAbsent -Change { param ($Scrobbles, $Save) & $Save @() }
            }

            $result | Should -Be 'Absent'
        }

        It 'Takes no lock when -SkipIfAbsent was given and there is no file' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Mock Enter-LFMScrobbleQueueLock

                $null = Update-LFMScrobbleQueue -SkipIfAbsent -Change { param ($Scrobbles, $Save) }

                Should -Invoke Enter-LFMScrobbleQueueLock -Exactly -Times 0 -Scope It
            }
        }

        It 'Creates nothing on disk when -SkipIfAbsent was given and there is no file' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                $null = Update-LFMScrobbleQueue -SkipIfAbsent -Change { param ($Scrobbles, $Save) & $Save @() }
            }

            Test-Path -LiteralPath (Split-Path -Path $queuePath -Parent) | Should -BeFalse
        }

        # Queueing the first Pending Scrobble on a machine has no file to find and has to
        # make one, which is why the shortcut is asked for rather than assumed.
        It 'Runs the change on an absent queue when -SkipIfAbsent was not given' {
            $result = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Update-LFMScrobbleQueue -Change {
                    param ($Scrobbles, $Save)
                    & $Save @([pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
                }
            }

            $result | Should -Be 'Updated'
            Test-Path -LiteralPath $queuePath | Should -BeTrue
        }
    }
}
