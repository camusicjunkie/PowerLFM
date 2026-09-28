Describe 'Clear-LFMScrobbleQueue: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }

        Mock Enter-LFMScrobbleQueueLock { [IO.MemoryStream]::new() } -ModuleName 'PowerLFM'
        Mock Export-LFMScrobbleQueue -ModuleName 'PowerLFM'
        Mock Import-LFMScrobbleQueue -ModuleName 'PowerLFM' -MockWith {
            [pscustomobject] @{
                Version   = 1
                Scrobbles = @(
                    [pscustomobject] @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800 }
                )
            }
        }
    }

    Context 'Execution' {

        It 'Discards every pending scrobble' {
            Clear-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName     = 'Export-LFMScrobbleQueue'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = { @($Queue.Scrobbles).Count -eq 0 }
            }
            Should -Invoke @siParams
        }

        It 'Holds the queue lock while clearing' {
            Clear-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName = 'Enter-LFMScrobbleQueueLock'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Writes nothing when another session holds the queue' {
            Mock Enter-LFMScrobbleQueueLock { } -ModuleName 'PowerLFM'

            Clear-LFMScrobbleQueue -Confirm:$false -WarningAction SilentlyContinue

            $siParams = @{
                CommandName = 'Export-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Writes nothing when the queue is already empty' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = @() }
            } -ModuleName 'PowerLFM'

            Clear-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName = 'Export-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        It 'Names how many pending scrobbles it is discarding' {
            $output = Clear-LFMScrobbleQueue -Confirm:$false -Verbose 4>&1

            $output -join "`n" | Should -Match 'Performing the operation "Discarding" on target "1 pending scrobbles".'
        }

        It 'Discards nothing when -WhatIf is used' {
            Clear-LFMScrobbleQueue -WhatIf

            $siParams = @{
                CommandName = 'Export-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }
    }
}
