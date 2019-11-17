function Get-LFMUserLovedTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Track')]
    param (
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
            'method' = 'user.getLovedTracks'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
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

            foreach ($track in $irm.LovedTracks.Track) {
                $trackInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.Track'
                    'Track' = $track.Name
                    'TrackUrl' = [uri] $track.Url
                    'TrackId' = $track.Mbid
                    'Artist' = $track.Artist.Name
                    'ArtistUrl' = [uri] $track.Artist.Url
                    'ArtistId' = $track.Artist.Mbid
                    'Date' = ConvertFrom-UnixTime -UnixTime $track.Date.Uts -Local
                }

                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
