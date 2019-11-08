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

    $noCommonParams = Remove-CommonParameter $PSBoundParameters
    $convertedParams = ConvertTo-LFMParameter $noCommonParams

    $query = New-LFMApiQuery ($convertedParams + $apiParams)
    $apiUrl = "$baseUrl/?$query"

    try {
        $irm = Invoke-LFMApiUri -Uri $apiUrl

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
    catch {
        throw $_
    }
}
