function Get-LFMTagTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTracks')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'tag.getTopTracks' -Parameter $PSBoundParameters

        foreach ($track in $irm.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopTracks'
                'Track' = $track.Name
                'TrackId' = $track.Mbid
                'TrackUrl' = [uri] $track.Url
                'Artist' = $track.Artist.Name
                'ArtistId' = $track.Artist.Mbid
                'ArtistUrl' = [uri] $track.Artist.Url
                'Rank' = [int] $track.'@attr'.Rank
                'Duration' = [int] $track.Duration
            }

            Write-Output $trackInfo
        }
    }
}
