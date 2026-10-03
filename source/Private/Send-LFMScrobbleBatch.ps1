function Send-LFMScrobbleBatch {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [psobject[]] $Scrobble
    )

    # track.scrobble takes up to 50 plays in one call. Invoke-LFMApiMethod numbers them
    # with Last.fm's name[i] notation; each play carries only the details it has.
    $batch = foreach ($play in $Scrobble) {
        $parameters = @{
            Artist    = $play.Artist
            Track     = $play.Track
            Timestamp = $play.Timestamp
        }
        foreach ($optional in 'Album', 'TrackNumber', 'Duration', 'Id') {
            if ($play.$optional) { $parameters[$optional] = $play.$optional }
        }
        $parameters
    }

    $irm = Invoke-LFMApiMethod -Method 'track.scrobble' -Batch $batch

    Write-Output @($irm.Scrobbles.Scrobble)
}
