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
        #
        # Names are normalised to one composition first. An 'e' followed by a combining
        # acute and a precomposed 'e-acute' are the same letter to Last.fm, both are valid
        # UTF-8, and both survive the queue file, so a queue can genuinely hold the pair -
        # a name pasted from one source and one typed at another. Left as written, the two
        # spellings are the same play to a culture-sensitive comparison and two plays to an
        # ordinal one, which is how the module came to hold two definitions of one term.
        #
        # An identity is compared through $scrobbleIdentityComparer wherever it is compared -
        # by the duplicate check in Add-LFMPendingScrobble and by the accounted set in
        # Send-LFMScrobbleQueue - so the two halves of the queue agree on what makes two
        # entries the same play.
        $artist = [string] $Scrobble.Artist
        $track = [string] $Scrobble.Track

        # A name holding a lone surrogate cannot be normalised and throws, and an identity
        # that can throw is one a Flush can die on, under the hold, over a single malformed
        # name in a queue file it did not write. Such a name is left as it was found: still
        # one identity, still compared the same way everywhere, which is all identity
        # promises. Whichever field normalised before the throw keeps its normalised form,
        # which is deterministic for a given name and is the point.
        try {
            $artist = $artist.Normalize([Text.NormalizationForm]::FormC)
            $track = $track.Normalize([Text.NormalizationForm]::FormC)
        }
        catch [ArgumentException] { }

        ($artist, $track, $Scrobble.Timestamp) -join [char] 31
    }
}
