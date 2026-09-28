Describe 'Get-LFMScrobbleQueue: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
        $unixTimestamp = ([datetimeoffset] '2026-09-28T12:00:00Z').ToUnixTimeSeconds()

        Mock Get-LFMSessionKeyFingerprint { 'FINGERPRINT' } -ModuleName 'PowerLFM'
        Mock Import-LFMScrobbleQueue -ModuleName 'PowerLFM' -MockWith {
            [pscustomobject] @{
                Version   = 1
                Scrobbles = @(
                    [pscustomobject] @{
                        Artist                = 'Opeth'
                        Album                 = 'Damnation'
                        Track                 = 'Windowpane'
                        Timestamp             = $unixTimestamp
                        TrackNumber           = 1
                        Duration              = 469
                        Id                    = $null
                        SessionKeyFingerprint = 'FINGERPRINT'
                    }
                    [pscustomobject] @{
                        Artist                = 'Katatonia'
                        Album                 = 'Viva Emptiness'
                        Track                 = 'Ghost Of The Sun'
                        Timestamp             = $unixTimestamp + 300
                        TrackNumber           = 1
                        Duration              = 231
                        Id                    = $null
                        SessionKeyFingerprint = 'SOMEONE ELSE'
                    }
                )
            }
        }
    }

    Context 'Output' {

        It 'Outputs every pending scrobble in the queue' {
            $output = Get-LFMScrobbleQueue

            @($output).Count | Should -Be 2
        }

        It 'Outputs pending scrobbles rather than scrobbles' {
            $output = Get-LFMScrobbleQueue

            $output[0].PSTypeNames | Should -Contain 'PowerLFM.Track.PendingScrobble'
        }

        It 'Converts the stored timestamp back to a local datetime' {
            $output = Get-LFMScrobbleQueue

            $output[0].Timestamp | Should -BeOfType [datetime]
            $output[0].Timestamp.ToUniversalTime() | Should -Be ([datetime] '2026-09-28T12:00:00Z').ToUniversalTime()
        }

        It 'Keeps the details a scrobble needs to be submitted' {
            $output = Get-LFMScrobbleQueue

            $output[0].Artist | Should -Be 'Opeth'
            $output[0].Album | Should -Be 'Damnation'
            $output[0].Track | Should -Be 'Windowpane'
            $output[0].Duration | Should -Be 469
        }

        It 'Shows which pending scrobbles the loaded configuration can submit' {
            $output = Get-LFMScrobbleQueue

            $output[0].MatchesConfiguration | Should -BeTrue
            $output[1].MatchesConfiguration | Should -BeFalse
        }

        It 'Never claims a match when no configuration is loaded' {
            Mock Get-LFMSessionKeyFingerprint { throw 'No configuration is loaded.' } -ModuleName 'PowerLFM'

            $output = Get-LFMScrobbleQueue

            $output.MatchesConfiguration | Should -Not -Contain $true
        }

        It 'Outputs nothing when the queue is empty' {
            Mock Import-LFMScrobbleQueue {
                [pscustomobject] @{ Version = 1; Scrobbles = @() }
            } -ModuleName 'PowerLFM'

            Get-LFMScrobbleQueue | Should -BeNullOrEmpty
        }
    }
}
