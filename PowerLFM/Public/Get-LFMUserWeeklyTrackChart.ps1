function Get-LFMUserWeeklyTrackChart {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyTrackChart')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $EndDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName
    )

    begin {
        $apiParams = @{
            'method' = 'user.getWeeklyTrackChart'
            'api_key' = $script:LFMConfig.APIKey
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

            foreach ($track in $irm.WeeklyTrackChart.Track) {
                $trackInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.WeeklyTrackChart'
                    'Track' = $track.Name
                    'Url' = [uri] $track.Url
                    'Id' = $track.Mbid
                    'Artist' = $track.Artist.'#text'
                    'ArtistId' = $track.Artist.Mbid
                    'PlayCount' = [int] $track.PlayCount
                    'StartDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyTrackChart.'@attr'.From -Local
                    'EndDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyTrackChart.'@attr'.To -Local
                }

                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
