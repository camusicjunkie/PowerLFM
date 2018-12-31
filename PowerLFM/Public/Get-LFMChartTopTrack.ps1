function Get-LFMChartTopTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopTracks')]
    param (
        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    $apiParams = @{
        'method' = 'chart.getTopTracks'
        'api_key' = $LFMConfig.APIKey
        'format' = 'json'
    }

    switch ($PSBoundParameters.Keys) {
        'Limit' {$apiParams.add('limit', $Limit)}
        'Page' {$apiParams.add('page', $Page)}
    }

    #Building string to append to base url
    $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
        "$($_.Name)=$($_.Value)"
    }
    $string = $keyValues -join '&'

    $apiUrl = "$baseUrl/?$string"

    $irm = Invoke-RestMethod -Uri $apiUrl

    foreach ($track in $irm.Tracks.Track) {
        $trackInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Chart.TopArtists'
            'Track' = $track.Name
            'TrackId' = $track.Mbid
            'TrackUrl' = $track.Url
            'Artist' = $track.Artist.Name
            'ArtistId' = $track.Artist.Mbid
            'ArtistUrl' = $track.Artist.Url
            'Duration' = $track.Duration
            'Listeners' = [int] $track.Listeners
            'PlayCount' = [int] $track.PlayCount
            'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
        }

        Write-Output $trackInfo
    }
}
