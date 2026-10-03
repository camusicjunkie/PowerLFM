function Get-LFMChartTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopTracks')]
    param (
        [Parameter()]
        [ValidateRange(1, 119)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'chart.getTopTracks' -Parameter $PSBoundParameters

        foreach ($track in $irm.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Chart.TopTracks'
                'Track' = $track.Name
                'TrackId' = $track.Mbid
                'TrackUrl' = [uri] $track.Url
                'Artist' = $track.Artist.Name
                'ArtistId' = $track.Artist.Mbid
                'ArtistUrl' = [uri] $track.Artist.Url
                'Duration' = [int] $track.Duration
                'Listeners' = [int] $track.Listeners
                'PlayCount' = [int] $track.PlayCount
            }

            Write-Output $trackInfo
        }
    }
}
