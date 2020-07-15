function Get-LFMUserTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopTrack')]
    param (
        [Parameter()]
        [ValidateSet('Overall', '7 Days', '1 Month',
                     '3 Months', '6 Months', '1 Year')]
        [string] $TimePeriod,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getTopTracks'
            'api_key' = $script:LFMConfig.ApiKey
            'sk' = $script:LFMConfig.SessionKey
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

            foreach ($track in $irm.TopTracks.Track) {
                $trackInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.TopTrack'
                    'Track' = $track.Name
                    'PlayCount' = [int] $track.PlayCount
                    'TrackUrl' = [uri] $track.Url
                    'TrackId' = $track.Mbid
                    'Artist' = $track.Artist.Name
                    'ArtistUrl' = [uri] $track.Artist.Url
                    'ArtistId' = $track.Artist.Mbid
                }

                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
