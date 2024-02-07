function Get-LFMGeoTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Geo.TopTracks')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Country,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $City,

        [Parameter()]
        [ValidateRange(1, 119)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'geo.getTopTracks'
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
                    'PSTypeName' = 'PowerLFM.Geo.TopTracks'
                    'Track' = $track.Name
                    'TrackId' = $track.Mbid
                    'TrackUrl' = [uri] $track.Url
                    'Artist' = $track.Artist.Name
                    'ArtistId' = $track.Artist.Mbid
                    'ArtistUrl' = [uri] $track.Artist.Url
                    'Rank' = [int] $track.'@attr'.Rank
                    'Listeners' = [int] $track.Listeners
                }

                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
