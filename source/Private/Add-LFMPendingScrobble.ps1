function Add-LFMPendingScrobble {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    [OutputType('PowerLFM.Track.PendingScrobble')]
    param (
        [Parameter(Mandatory)]
        [string] $Artist,

        [Parameter(Mandatory)]
        [string] $Track,

        [Parameter(Mandatory)]
        [datetime] $Timestamp,

        [string] $Album,

        [guid] $Id,

        [int] $TrackNumber,

        [int] $Duration
    )

    # Nothing is returned when the Pending Scrobble could not be queued, and the warning
    # explaining why has already been written. Set-LFMTrackScrobble reads that silence as
    # its cue to let the original transport failure surface: a visibly failed Scrobble
    # beats a lost one.
    try {
        $entry = [pscustomobject] @{
            Artist                = $Artist
            Album                 = if ($PSBoundParameters.ContainsKey('Album')) { $Album } else { $null }
            Track                 = $Track
            # Converted here, while Kind is still trustworthy. A datetime round-tripped
            # through JSON comes back Unspecified, which ConvertTo-UnixTime reads as
            # already-UTC, silently shifting the play by the user's offset.
            Timestamp             = ConvertTo-UnixTime -Date $Timestamp
            TrackNumber           = if ($PSBoundParameters.ContainsKey('TrackNumber')) { $TrackNumber } else { $null }
            Duration              = if ($PSBoundParameters.ContainsKey('Duration')) { $Duration } else { $null }
            Id                    = if ($PSBoundParameters.ContainsKey('Id')) { $Id.ToString() } else { $null }
            SessionKeyFingerprint = Get-LFMSessionKeyFingerprint
        }

        # No -SkipIfAbsent: the first Pending Scrobble on a machine has no queue file to
        # find and has to make one.
        $result = Update-LFMScrobbleQueue -Change {
            param ($Scrobbles, $Save)

            # A second entry with the same Scrobble Identity is the same play, so it is
            # dropped rather than queued twice.
            $identity = Get-LFMScrobbleIdentity -Scrobble $entry
            $duplicates = $Scrobbles.Where({ (Get-LFMScrobbleIdentity -Scrobble $_) -eq $identity })

            if ($duplicates.Count -eq 0) {
                & $Save @($Scrobbles + $entry)
                Write-Warning ($localizedData.warningScrobbleQueued -f $Artist, $Track)
                $queued = @($Scrobbles).Count + 1
            }
            else {
                # Nothing was written and nothing was lost, but the caller still needs to
                # know Last.fm has not recorded this play.
                Write-Warning ($localizedData.warningScrobbleAlreadyQueued -f $Artist, $Track)
                $queued = @($Scrobbles).Count
            }

            if ($queued -gt $scrobbleQueueWarningThreshold) {
                Write-Warning ($localizedData.warningScrobbleQueueLarge -f $queued)
            }
        }

        if ($result -ne 'Updated') {
            Write-Warning ($localizedData.warningScrobbleQueueLocked -f $Artist, $Track)
            return
        }

        # Emitted out here rather than from the change: the entry is built before the queue
        # is ever read, and a change returns nothing.
        $entry | ConvertTo-LFMPendingScrobble -Fingerprint $entry.SessionKeyFingerprint
    }
    catch {
        Write-Warning ($localizedData.warningScrobbleQueueFailed -f $_.Exception.Message)
    }
}
