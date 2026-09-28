function Get-LFMScrobbleIdentity {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [psobject] $Scrobble
    )

    process {
        # Artist, Track and Timestamp are what make a Scrobble one play rather than
        # another - the Scrobble Queue has no identifier of its own to lean on, and a
        # position in the file stops being an identity the moment the file is rewritten.
        #
        # Joined on a unit separator rather than a printable character: a name that
        # contains the separator runs into the next field, and 'AC|DC' playing 'Thunder'
        # would be the same play as 'AC' playing 'DC|Thunder'.
        ($Scrobble.Artist, $Scrobble.Track, $Scrobble.Timestamp) -join [char] 31
    }
}
