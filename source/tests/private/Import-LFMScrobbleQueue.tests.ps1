Describe 'Import-LFMScrobbleQueue: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    BeforeEach {
        $queuePath = Join-Path -Path $TestDrive -ChildPath 'ScrobbleQueue.json'
        Remove-Item -LiteralPath $queuePath -Force -ErrorAction SilentlyContinue

        InModuleScope @module -Parameters @{ QueuePath = $queuePath } {
            param ($QueuePath)
            $script:testQueuePath = $QueuePath
        }
    }

    It 'Returns an empty queue when no queue file exists' {
        $result = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Import-LFMScrobbleQueue
        }

        $result.Version | Should -Be 1
        @($result.Scrobbles).Count | Should -Be 0
    }

    It 'Returns an empty queue when the queue file is empty' {
        Set-Content -LiteralPath $queuePath -Value '' -NoNewline

        $result = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Import-LFMScrobbleQueue
        }

        @($result.Scrobbles).Count | Should -Be 0
    }

    It 'Reads the pending scrobbles out of the queue file' {
        $json = @{
            Version   = 1
            Scrobbles = @(
                @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 }
            )
        } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath $queuePath -Value $json

        $result = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Import-LFMScrobbleQueue
        }

        @($result.Scrobbles).Count | Should -Be 1
        $result.Scrobbles[0].Artist | Should -Be 'Opeth'
        $result.Scrobbles[0].Timestamp | Should -Be 1790596800
    }

    It 'Returns a single pending scrobble as a collection' {
        $json = @{
            Version   = 1
            Scrobbles = @(@{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 })
        } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath $queuePath -Value $json

        $result = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Import-LFMScrobbleQueue
        }

        $result.Scrobbles.GetType().IsArray | Should -BeTrue
    }

    It 'Returns an empty queue when the queue file holds no pending scrobbles' {
        Set-Content -LiteralPath $queuePath -Value '{ "Version": 1, "Scrobbles": null }'

        $result = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Import-LFMScrobbleQueue
        }

        @($result.Scrobbles).Count | Should -Be 0
    }

    It 'Brings a queue written by an older version forward' {
        $json = @{
            Version   = 0
            Scrobbles = @(@{ Artist = 'Opeth' })
        } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath $queuePath -Value $json

        $result = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }

            $original = $script:scrobbleQueueMigrations
            $script:scrobbleQueueMigrations = @{
                0 = {
                    param ($Queue)
                    [pscustomobject] @{
                        Scrobbles = @($Queue.Scrobbles).ForEach({
                            [pscustomobject] @{ Artist = $_.Artist; Track = 'Windowpane' }
                        })
                    }
                }
            }

            try { Import-LFMScrobbleQueue }
            finally { $script:scrobbleQueueMigrations = $original }
        }

        $result.Version | Should -Be 1
        @($result.Scrobbles).Count | Should -Be 1
        $result.Scrobbles[0].Track | Should -Be 'Windowpane'
    }

    It 'Leaves the migrated queue on disk at the version it was written with' {
        $json = @{ Version = 0; Scrobbles = @(@{ Artist = 'Opeth' }) } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath $queuePath -Value $json

        $null = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }

            $original = $script:scrobbleQueueMigrations
            $script:scrobbleQueueMigrations = @{
                0 = { param ($Queue) [pscustomobject] @{ Scrobbles = @($Queue.Scrobbles) } }
            }

            try { Import-LFMScrobbleQueue }
            finally { $script:scrobbleQueueMigrations = $original }
        }

        $onDisk = Get-Content -LiteralPath $queuePath -Raw | ConvertFrom-Json
        $onDisk.Version | Should -Be 0
    }

    It 'Refuses to read a queue written by a newer version' {
        $json = @{ Version = 99; Scrobbles = @() } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath $queuePath -Value $json

        {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Import-LFMScrobbleQueue
            }
        } | Should -Throw '*written by version 99*'
    }

    It 'Gives up rather than reporting an empty queue when the file never comes free' {
        # A read that lands while a Queue Update is swapping the file in waits and tries
        # again, because the queue is there directly afterwards. A file held open for
        # longer than that is not a swap in flight, and answering "nothing is pending"
        # would be the one wrong answer: the pending scrobbles are still there.
        Set-Content -LiteralPath $queuePath -Value (@{ Version = 1; Scrobbles = @() } | ConvertTo-Json)
        $held = [IO.File]::Open($queuePath, 'Open', 'ReadWrite', 'None')

        try {
            $caught = try {
                InModuleScope @module {
                    Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                    Import-LFMScrobbleQueue
                }
                $null
            }
            catch { $_ }

            $caught | Should -Not -BeNullOrEmpty
            # Thrown from a .NET call, so the reason is one exception further in.
            $caught.Exception.InnerException | Should -BeOfType [IO.IOException]
        }
        finally { $held.Dispose() }
    }

    It 'Names the queue file when it refuses to read it' {
        $json = @{ Version = 99; Scrobbles = @() } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath $queuePath -Value $json

        $message = try {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Import-LFMScrobbleQueue
            }
        }
        catch { $_.Exception.Message }

        $message | Should -BeLike "*$queuePath*"
    }
}
