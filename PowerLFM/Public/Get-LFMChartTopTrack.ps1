function Get-LFMChartTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopTracks')]
    param (
        [Parameter()]
        [ValidateRange(1,119)]
        [int] $Limit,

        [int] $Page
    )

    $apiParams = @{
        'method' = 'chart.getTopTracks'
        'api_key' = $LFMConfig.APIKey
        'format' = 'json'
    }

    switch ($PSBoundParameters.Keys) {
        'Limit' {$apiParams.Add('limit', $Limit)}
        'Page' {$apiParams.Add('page', $Page)}
    }

    #Building string to append to base url
    $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
        "$($_.Name)=$($_.Value)"
    }
    $string = $keyValues -join '&'

    $apiUrl = "$baseUrl/?$string"

    $irm = Invoke-LFMApiUri -Uri $apiUrl
    if ($irm.Error) {Write-Output $irm; return}

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
