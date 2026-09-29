Describe 'Get-LFMScrobbleIdentity: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }

        $newEntry = {
            param (
                [string] $Artist = 'Opeth',
                [string] $Track = 'Windowpane',
                [long] $Timestamp = 1790596800
            )

            [pscustomobject] @{
                Artist                = $Artist
                Track                 = $Track
                Timestamp             = $Timestamp
                Album                 = 'Damnation'
                SessionKeyFingerprint = 'FINGERPRINT'
            }
        }
    }

    It 'Gives the same identity to the same play' {
        $first = InModuleScope @module -Parameters @{ Entry = & $newEntry } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }
        $second = InModuleScope @module -Parameters @{ Entry = & $newEntry } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }

        $first | Should -BeExactly $second
    }

    It 'Ignores everything but artist, track and timestamp' {
        $plain = InModuleScope @module -Parameters @{ Entry = & $newEntry } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }

        $decorated = InModuleScope @module -Parameters @{ Entry = & $newEntry } {
            param ($Entry)
            $Entry.Album = 'Blackwater Park'
            $Entry.SessionKeyFingerprint = 'SOMEONE ELSE'
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }

        $plain | Should -BeExactly $decorated
    }

    It 'Gives a different identity to <Name>' -ForEach @(
        @{ Name = 'another artist'; Entry = @{ Artist = 'Katatonia' } }
        @{ Name = 'another track'; Entry = @{ Track = 'Harvest' } }
        @{ Name = 'another moment'; Entry = @{ Timestamp = 1790596801 } }
    ) {
        $mine = InModuleScope @module -Parameters @{ Entry = & $newEntry } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }
        $theirs = InModuleScope @module -Parameters @{ Entry = & $newEntry @Entry } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }

        $mine | Should -Not -BeExactly $theirs
    }

    It 'Gives one identity to both spellings of the same name' {
        # Both are valid UTF-8, both survive the queue file, and Last.fm reads them as the
        # same artist, so the queue and the flush have to read them as one scrobble.
        $precomposed = 'Beyonc' + [char] 0x00E9
        $combining = 'Beyonce' + [char] 0x0301

        $first = InModuleScope @module -Parameters @{ Entry = & $newEntry -Artist $precomposed } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }
        $second = InModuleScope @module -Parameters @{ Entry = & $newEntry -Artist $combining } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }

        $first | Should -BeExactly $second
    }

    It 'Gives an identity to a name that cannot be normalised' {
        # A lone surrogate throws on normalisation. A Flush computes an identity for every
        # entry it reads, under the hold, so one malformed name in the file must not be able
        # to take the whole Flush down with it.
        $malformed = 'Opeth' + [char] 0xD800

        $first = InModuleScope @module -Parameters @{ Entry = & $newEntry -Artist $malformed } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }
        $second = InModuleScope @module -Parameters @{ Entry = & $newEntry -Artist $malformed } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }

        $first | Should -Not -BeNullOrEmpty
        $first | Should -BeExactly $second
    }

    It 'Does not let a name run into the next field' {
        $first = InModuleScope @module -Parameters @{ Entry = & $newEntry -Artist 'AC|DC' -Track 'Thunder' } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }
        $second = InModuleScope @module -Parameters @{ Entry = & $newEntry -Artist 'AC' -Track 'DC|Thunder' } {
            param ($Entry)
            Get-LFMScrobbleIdentity -Scrobble $Entry
        }

        $first | Should -Not -BeExactly $second
    }
}
