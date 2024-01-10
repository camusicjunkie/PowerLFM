function Search-LFMAlbum {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Album.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'album.search'
            'api_key' = $script:LFMConfig.ApiKey
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

            foreach ($match in $irm.Results.AlbumMatches.Album) {
                $matchInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Album.Search'
                    'Album' = $match.Name
                    'Artist' = $match.Artist
                    'Id' = $match.Mbid
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
