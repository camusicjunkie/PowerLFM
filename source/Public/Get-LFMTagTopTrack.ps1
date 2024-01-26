function Get-LFMTagTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTracks')]
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
            'method' = 'tag.getTopTracks'
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

            foreach ($track in $irm.Tracks.Track) {
                $trackInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Tag.TopTracks'
                    'Track' = $track.Name
                    'TrackId' = $track.Mbid
                    'TrackUrl' = [uri] $track.Url
                    'Artist' = $track.Artist.Name
                    'ArtistId' = $track.Artist.Mbid
                    'ArtistUrl' = [uri] $track.Artist.Url
                    'Rank' = [int] $track.'@attr'.Rank
                    'Duration' = [int] $track.Duration
                }

                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
