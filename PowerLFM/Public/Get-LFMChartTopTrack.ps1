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

    try {
        $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        if ($irm.error) {
            [pscustomobject] @{
                'Error' = $irm.error
                'Message' = $irm.message
            }
            return
        }
    }
    catch {
        $response = $_.errorDetails.message | ConvertFrom-Json

        [pscustomobject] @{
            'Error' = $response.error
            'Message' = $response.message
        }
        return
    }

    foreach ($track in $irm.Tracks.Track) {
        $trackInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Chart.TopArtists'
            'Track' = $track.Name
            'TrackId' = [guid] $track.Mbid
            'TrackUrl' = [uri] $track.Url
            'Artist' = $track.Artist.Name
            'ArtistId' = [guid] $track.Artist.Mbid
            'ArtistUrl' = [uri] $track.Artist.Url
            'Duration' = [int] $track.Duration
            'Listeners' = [int] $track.Listeners
            'PlayCount' = [int] $track.PlayCount
            'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
        }

        Write-Output $trackInfo
    }
}
