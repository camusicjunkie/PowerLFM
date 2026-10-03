function Get-LFMChartTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopArtists')]
    param (
        [Parameter()]
        [ValidateRange(1, 119)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'chart.getTopArtists' -Parameter $PSBoundParameters

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
}
