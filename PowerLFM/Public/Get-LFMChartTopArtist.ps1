function Get-LFMChartTopArtist {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopArtists')]
    param (
        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    $apiParams = @{
        'method' = 'chart.getTopArtists'
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

    foreach ($artist in $irm.Artists.Artist) {
        $artistInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Chart.TopArtists'
            'Artist' = $artist.Name
            'Id' = $artist.Mbid
            'Url' = $artist.Url
            'Listeners' = [int] $artist.Listeners
            'PlayCount' = [int] $artist.PlayCount
            'ImageUrl' = $artist.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
        }

        Write-Output $artistInfo
    }
}
