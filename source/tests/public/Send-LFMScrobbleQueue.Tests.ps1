Describe 'Send-LFMScrobbleQueue: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
        $unixTimestamp = ([datetimeoffset] '2026-09-28T12:00:00Z').ToUnixTimeSeconds()

        $newQueuedScrobble = {
            param (
                [int] $Count,
                [string] $Fingerprint = 'FINGERPRINT'
            )

            @(1..$Count).ForEach({
                [pscustomobject] @{
                    Artist                = 'Opeth'
                    Album                 = 'Damnation'
                    Track                 = "Track $_"
                    Timestamp             = 1790596800 + $_
                    TrackNumber           = $null
                    Duration              = $null
                    Id                    = $null
                    SessionKeyFingerprint = $Fingerprint
                }
            })
        }

        $newScrobbleResult = {
            param (
                [int] $Count,
                [int] $Code = 0
            )

            @(1..$Count).ForEach({
                [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = $Code } }
            })
        }

        $queuedOne = & $newQueuedScrobble -Count 1
        $queuedThree = & $newQueuedScrobble -Count 3
        $queuedManyBatches = & $newQueuedScrobble -Count 120
        $queuedSomeoneElse = & $newQueuedScrobble -Count 1 -Fingerprint 'SOMEONE ELSE'

        $resultsOne = & $newScrobbleResult -Count 1
        $resultsTwo = & $newScrobbleResult -Count 2
        $resultsThree = & $newScrobbleResult -Count 3
        $resultsOneTooOld = & $newScrobbleResult -Count 1 -Code 3
        $resultsOneOverDailyLimit = & $newScrobbleResult -Count 1 -Code 5
    }

    BeforeEach {
        Mock Test-Path { $true } -ModuleName 'PowerLFM'
        Mock Enter-LFMScrobbleQueueLock { [IO.MemoryStream]::new() } -ModuleName 'PowerLFM'
        Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' } -ModuleName 'PowerLFM'
        Mock Export-LFMScrobbleQueue -ModuleName 'PowerLFM'
        Mock Send-LFMScrobbleBatch -ModuleName 'PowerLFM'
    }

    Context 'Empty queue' {

        It 'Takes no lock when no queue file exists' {
            Mock Test-Path { $false } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName = 'Enter-LFMScrobbleQueueLock'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Submits nothing when the queue holds no pending scrobbles' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = @() }
            } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName = 'Send-LFMScrobbleBatch'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Submits nothing when another session holds the queue' {
            Mock Enter-LFMScrobbleQueueLock { } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName = 'Send-LFMScrobbleBatch'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }
    }

    Context 'Batching' {

        It 'Submits a small queue in a single call' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedThree }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsThree } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName     = 'Send-LFMScrobbleBatch'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = { $Scrobble.Count -eq 3 }
            }
            Should -Invoke @siParams
        }

        It 'Never submits more than fifty pending scrobbles in one call' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedManyBatches }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch {
                @(1..$Scrobble.Count).ForEach({ [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } } })
            } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName     = 'Send-LFMScrobbleBatch'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 0
                Scope           = 'It'
                ParameterFilter = { $Scrobble.Count -gt 50 }
            }
            Should -Invoke @siParams
        }

        It 'Splits a large queue across as many calls as it takes' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedManyBatches }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch {
                @(1..$Scrobble.Count).ForEach({ [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } } })
            } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName = 'Send-LFMScrobbleBatch'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 3
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Writes the queue back after every batch rather than at the end' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedManyBatches }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch {
                @(1..$Scrobble.Count).ForEach({ [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } } })
            } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

            $siParams = @{
                CommandName = 'Export-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 3
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Leaves an emptied queue behind' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedThree }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsThree } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false

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
    }

    Context 'Other credentials' {

        It 'Submits only the pending scrobbles this configuration captured' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = @($queuedOne) + @($queuedSomeoneElse) }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsOne } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -WarningAction SilentlyContinue

            $siParams = @{
                CommandName     = 'Send-LFMScrobbleBatch'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Scrobble.Count -eq 1 -and
                    $Scrobble.SessionKeyFingerprint -notcontains 'SOMEONE ELSE'
                }
            }
            Should -Invoke @siParams
        }

        It 'Leaves the pending scrobbles it cannot submit in the queue' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = @($queuedOne) + @($queuedSomeoneElse) }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsOne } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -WarningAction SilentlyContinue

            $siParams = @{
                CommandName     = 'Export-LFMScrobbleQueue'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    @($Queue.Scrobbles).Count -eq 1 -and
                    $Queue.Scrobbles[0].SessionKeyFingerprint -eq 'SOMEONE ELSE'
                }
            }
            Should -Invoke @siParams
        }

        It 'Warns about the pending scrobbles it cannot submit' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedSomeoneElse }
            } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -WarningVariable queueWarnings -WarningAction SilentlyContinue

            $queueWarnings.Message -join "`n" | Should -Match 'different credentials'
        }
    }

    Context 'Pending scrobbles Last.fm declines' {

        It 'Drops a pending scrobble Last.fm accounted for but did not record' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedOne }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsOneTooOld } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -WarningAction SilentlyContinue

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

        It 'Keeps a pending scrobble Last.fm may yet record' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedOne }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsOneOverDailyLimit } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -WarningVariable queueWarnings -WarningAction SilentlyContinue

            $siParams = @{
                CommandName     = 'Export-LFMScrobbleQueue'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = { @($Queue.Scrobbles).Count -eq 1 }
            }
            Should -Invoke @siParams

            $queueWarnings.Message -join "`n" | Should -Match 'still in the scrobble queue'
        }

        It 'Names the track and the reason it dropped one' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedOne }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsOneTooOld } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -WarningVariable queueWarnings -WarningAction SilentlyContinue

            $message = $queueWarnings.Message -join "`n"
            $message | Should -Match 'Track 1'
            $message | Should -Match 'Timestamp too far in the past'
        }
    }

    Context 'Failure' {

        It 'Stops submitting when a batch fails' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedManyBatches }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { throw 'Last.fm could not be reached.' } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -ErrorAction SilentlyContinue

            $siParams = @{
                CommandName = 'Send-LFMScrobbleBatch'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Keeps every unsent pending scrobble when a batch fails' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedThree }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { throw 'Last.fm could not be reached.' } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -ErrorAction SilentlyContinue

            $siParams = @{
                CommandName = 'Export-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Reports the failure as an error' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedThree }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { throw 'Last.fm could not be reached.' } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -ErrorVariable queueErrors -ErrorAction SilentlyContinue

            $queueErrors.Exception.Message -join "`n" | Should -Match 'Last.fm could not be reached.'
        }

        It 'Keeps a batch queued when Last.fm did not account for all of it' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedThree }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsTwo } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -Confirm:$false -ErrorAction SilentlyContinue

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

        It 'Names how many pending scrobbles it is submitting' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedThree }
            } -ModuleName 'PowerLFM'
            Mock Send-LFMScrobbleBatch { $resultsThree } -ModuleName 'PowerLFM'

            $output = Send-LFMScrobbleQueue -Confirm:$false -Verbose 4>&1

            $output -join "`n" | Should -Match 'Performing the operation "Submitting to Last.fm" on target "3 pending scrobbles played between .+ and .+".'
        }

        It 'Submits nothing when -WhatIf is used' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = $queuedThree }
            } -ModuleName 'PowerLFM'

            Send-LFMScrobbleQueue -WhatIf

            $siParams = @{
                CommandName = 'Send-LFMScrobbleBatch'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }
    }
}
