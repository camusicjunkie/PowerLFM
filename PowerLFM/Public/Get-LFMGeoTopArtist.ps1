function Get-LFMGeoTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Geo.TopArtists')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Country,

        [Parameter()]
        [ValidateRange(1, 119)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'geo.getTopArtists'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $convertedParams = ConvertTo-LFMParameter $noCommonParams

        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            foreach ($artist in $irm.TopArtists.Artist) {
                $artistInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Geo.TopArtists'
                    'Artist' = $artist.Name
                    'Id' = $artist.Mbid
                    'Url' = [uri] $artist.Url
                    'Listeners' = [int] $artist.Listeners
                }

                Write-Output $artistInfo
            }
        }
        catch {
            throw $_
        }
    }
}
