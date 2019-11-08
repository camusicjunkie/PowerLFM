function Get-LFMTagTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopArtists')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'tag.getTopArtists'
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
                    'PSTypeName' = 'PowerLFM.Tag.TopArtists'
                    'Artist' = $artist.Name
                    'ArtistId' = $artist.Mbid
                    'ArtistUrl' = [uri] $artist.Url
                    'Rank' = [int] $artist.'@attr'.Rank
                }

                Write-Output $artistInfo
            }
        }
        catch {
            throw $_
        }
    }
}
