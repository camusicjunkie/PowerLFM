function Search-LFMTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'track.search'
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

            foreach ($match in $irm.Results.TrackMatches.Track) {
                $matchInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Track.Search'
                    'Track' = $match.Name
                    'Artist' = $match.Artist
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
