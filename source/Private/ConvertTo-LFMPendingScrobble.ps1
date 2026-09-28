function ConvertTo-LFMPendingScrobble {
    [CmdletBinding()]
    [OutputType('PowerLFM.Track.PendingScrobble')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [psobject] $Entry,

        [string] $Fingerprint
    )

    process {
        [pscustomobject] @{
            PSTypeName           = 'PowerLFM.Track.PendingScrobble'
            Artist               = $Entry.Artist
            Album                = $Entry.Album
            Track                = $Entry.Track
            Timestamp            = ConvertFrom-UnixTime -UnixTime $Entry.Timestamp -Local
            TrackNumber          = $Entry.TrackNumber
            Duration             = $Entry.Duration
            Id                   = $Entry.Id
            MatchesConfiguration = -not [string]::IsNullOrEmpty($Fingerprint) -and
                                   $Entry.SessionKeyFingerprint -eq $Fingerprint
        }
    }
}
