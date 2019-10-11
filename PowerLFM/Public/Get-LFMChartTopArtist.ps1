function Get-LFMChartTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopArtists')]
    param (
        [Parameter()]
        [ValidateRange(1,119)]
        [int] $Limit,

        [int] $Page
    )

    $apiParams = @{
        'method' = 'chart.getTopArtists'
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

    foreach ($artist in $irm.Artists.Artist) {
        $artistInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Chart.TopArtists'
            'Artist' = $artist.Name
            'Id' = $artist.Mbid
            'Url' = [uri] $artist.Url
            'Listeners' = [int] $artist.Listeners
            'PlayCount' = [int] $artist.PlayCount
        }

        Write-Output $artistInfo
    }
}
