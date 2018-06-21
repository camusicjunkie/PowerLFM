function Get-LFMChartTopTrack {
    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopTracks')]
    param (
        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    #Default hashtable
    $apiParams = [ordered] @{
        'method' = 'chart.getTopTracks'
        'api_key' = $LFMConfig.APIKey
        'format' = 'json'
    }

    #Adding key/value to hashtable based off optional parameters
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
    $hash = $irm | ConvertTo-Hashtable
    
    foreach ($track in $hash.Tracks.Track) {
        $trackInfo = [pscustomobject] @{
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

        $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Chart.TopArtists')
        Write-Output $trackInfo
    }
}