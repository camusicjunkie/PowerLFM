function Search-LFMArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Artist.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter()]
        [ValidateRange(1,50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'artist.search'
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

            foreach ($match in $irm.Results.ArtistMatches.Artist) {
                $matchInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Artist.Search'
                    'Artist' = $match.Name
                    'Id' = $match.Mbid
                    'Listeners' = [int] $match.Listeners
                    'Url' = [uri] $match.Url
                }

                Write-Output $matchInfo
            }
        }
        catch {
            throw $_
        }
    }
}
