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

    $lock = Enter-LFMScrobbleQueueLock
    if ($null -eq $lock) {
        Write-Warning ($localizedData.warningScrobbleQueueLocked -f $Artist, $Track)
        return
    }

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

        $queue = Import-LFMScrobbleQueue
        $scrobbles = @($queue.Scrobbles)

        # Artist, track and timestamp identify a play. A second entry with the same
        # three is the same Scrobble, so it is dropped rather than queued twice.
        $duplicates = $scrobbles.Where({
            $_.Artist -eq $entry.Artist -and
            $_.Track -eq $entry.Track -and
            $_.Timestamp -eq $entry.Timestamp
        })

        if ($duplicates.Count -eq 0) {
            $queue.Scrobbles = $scrobbles + $entry
            Export-LFMScrobbleQueue -Queue $queue
            Write-Warning ($localizedData.warningScrobbleQueued -f $Artist, $Track)
        }
        else {
            # Nothing was written and nothing was lost, but the caller still needs to
            # know Last.fm has not recorded this play.
            Write-Warning ($localizedData.warningScrobbleAlreadyQueued -f $Artist, $Track)
        }

        $queued = @($queue.Scrobbles).Count
        if ($queued -gt $scrobbleQueueWarningThreshold) {
            Write-Warning ($localizedData.warningScrobbleQueueLarge -f $queued)
        }

        $entry | ConvertTo-LFMPendingScrobble -Fingerprint $entry.SessionKeyFingerprint
    }
    catch {
        Write-Warning ($localizedData.warningScrobbleQueueFailed -f $_.Exception.Message)
    }
    finally {
        $lock.Dispose()
    }
}
