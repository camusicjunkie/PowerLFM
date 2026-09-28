Describe 'Convert-LFMScrobbleQueueVersion: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
        $queuePath = 'TestDrive:\ScrobbleQueue.json'
    }

    It 'Returns a queue that is already at the current version unchanged' {
        $result = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            $queue = [pscustomobject] @{
                Version   = $scrobbleQueueVersion
                Scrobbles = @(@{ Artist = 'Opeth' })
            }

            Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations @{ }
        }

        $result.Version | Should -Be 1
        @($result.Scrobbles).Count | Should -Be 1
        $result.Scrobbles[0].Artist | Should -Be 'Opeth'
    }

    It 'Applies the migration that brings an older queue forward' {
        $result = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            $migrations = @{
                0 = { param ($Queue) [pscustomobject] @{ Scrobbles = @(@{ Artist = 'Opeth' }) } }
            }

            $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }

            Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 1
        }

        @($result.Scrobbles).Count | Should -Be 1
        $result.Scrobbles[0].Artist | Should -Be 'Opeth'
    }

    It 'Stamps the target version on the migrated queue' {
        $result = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            $migrations = @{
                0 = { param ($Queue) [pscustomobject] @{ Scrobbles = $Queue.Scrobbles } }
            }

            $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }

            Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 1
        }

        $result.Version | Should -Be 1
    }

    It 'Ignores the version a migration stamps on the queue it returns' {
        $result = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            $migrations = @{
                0 = { param ($Queue) [pscustomobject] @{ Version = 99; Scrobbles = @() } }
            }

            $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }

            Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 1
        }

        $result.Version | Should -Be 1
    }

    It 'Applies every migration in turn when more than one version separates the queue from the target' {
        $result = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            $migrations = @{
                0 = { param ($Queue) [pscustomobject] @{ Scrobbles = @($Queue.Scrobbles) + 'first' } }
                1 = { param ($Queue) [pscustomobject] @{ Scrobbles = @($Queue.Scrobbles) + 'second' } }
                2 = { param ($Queue) [pscustomobject] @{ Scrobbles = @($Queue.Scrobbles) + 'third' } }
            }

            $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }

            Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 3
        }

        $result.Version | Should -Be 3
        $result.Scrobbles | Should -Be @('first', 'second', 'third')
    }

    It 'Stops at the target version rather than applying every migration it holds' {
        $result = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            $migrations = @{
                0 = { param ($Queue) [pscustomobject] @{ Scrobbles = @($Queue.Scrobbles) + 'first' } }
                1 = { param ($Queue) [pscustomobject] @{ Scrobbles = @($Queue.Scrobbles) + 'second' } }
            }

            $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }

            Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 1
        }

        $result.Scrobbles | Should -Be @('first')
    }

    # The shipped table is the one thing the tests above substitute away, and the type it
    # is declared as decides whether an integer key is a key at all: an ordered dictionary
    # reads $table[1] as the second entry, so the first real migration would silently run
    # the wrong step.
    It 'Looks a migration up on the shipped table by version rather than by position' {
        $result = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            # Built as whatever type the shipped table is, so the lookup under test is the
            # one a real migration would get.
            $migrations = [Activator]::CreateInstance($scrobbleQueueMigrations.GetType())
            $migrations.Add(1, { param ($Queue) [pscustomobject] @{ Scrobbles = @('from one') } })
            $migrations.Add(0, { param ($Queue) [pscustomobject] @{ Scrobbles = @('from zero') } })

            $queue = [pscustomobject] @{ Version = 1; Scrobbles = @() }

            Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 2
        }

        $result.Scrobbles | Should -Be @('from one')
    }

    It 'Refuses a queue written by a newer version than this module understands' {
        {
            InModuleScope @module -Parameters @{ Path = $queuePath } {
                param ($Path)

                $queue = [pscustomobject] @{ Version = 99; Scrobbles = @() }
                Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations @{ } -TargetVersion 1
            }
        } | Should -Throw '*written by version 99*'
    }

    It 'Refuses a queue no migration can bring forward' {
        {
            InModuleScope @module -Parameters @{ Path = $queuePath } {
                param ($Path)

                $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }
                Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations @{ } -TargetVersion 1
            }
        } | Should -Throw '*no migration from version 0*'
    }

    It 'Refuses a queue whose version is missing' {
        {
            InModuleScope @module -Parameters @{ Path = $queuePath } {
                param ($Path)

                $queue = [pscustomobject] @{ Scrobbles = @() }
                Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations @{ }
            }
        } | Should -Throw '*unrecognised version*'
    }

    It 'Refuses a queue whose version is not a number' {
        {
            InModuleScope @module -Parameters @{ Path = $queuePath } {
                param ($Path)

                $queue = [pscustomobject] @{ Version = 'one'; Scrobbles = @() }
                Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations @{ }
            }
        } | Should -Throw '*unrecognised version (one)*'
    }

    It 'Names the queue it is refusing' {
        $message = InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            try {
                $queue = [pscustomobject] @{ Version = 99; Scrobbles = @() }
                Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations @{ } -TargetVersion 1
            }
            catch { $_.Exception.Message }
        }

        $message | Should -BeLike "*$queuePath*"
    }

    It 'Reports which migration failed when one throws' {
        {
            InModuleScope @module -Parameters @{ Path = $queuePath } {
                param ($Path)

                $migrations = @{
                    0 = { param ($Queue) throw 'the disk caught fire' }
                }

                $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }
                Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 1
            }
        } | Should -Throw '*from version 0 to version 1*the disk caught fire*'
    }

    It 'Refuses to carry on when a migration returns nothing' {
        {
            InModuleScope @module -Parameters @{ Path = $queuePath } {
                param ($Path)

                $migrations = @{
                    0 = { param ($Queue) }
                }

                $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }
                Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 1
            }
        } | Should -Throw '*from version 0 to version 1*'
    }

    It 'Leaves the queue on disk alone' {
        InModuleScope @module -Parameters @{ Path = $queuePath } {
            param ($Path)

            Mock Export-LFMScrobbleQueue { }

            $migrations = @{
                0 = { param ($Queue) [pscustomobject] @{ Scrobbles = @() } }
            }

            $queue = [pscustomobject] @{ Version = 0; Scrobbles = @() }
            $null = Convert-LFMScrobbleQueueVersion -Queue $queue -Path $Path -Migrations $migrations -TargetVersion 1

            Should -Invoke Export-LFMScrobbleQueue -Exactly -Times 0
        }
    }
}
