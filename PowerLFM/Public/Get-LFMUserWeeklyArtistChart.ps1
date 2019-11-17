function Get-LFMUserWeeklyArtistChart {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyArtistChart')]
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
            'method' = 'user.getWeeklyArtistChart'
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

            foreach ($artist in $irm.WeeklyArtistChart.Artist) {
                $artistInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.WeeklyArtistChart'
                    'Artist' = $artist.Name
                    'Url' = [uri] $artist.Url
                    'Id' = $artist.Mbid
                    'PlayCount' = [int] $artist.PlayCount
                    'StartDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyArtistChart.'@attr'.From -Local
                    'EndDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyArtistChart.'@attr'.To -Local
                }

                Write-Output $artistInfo
            }
        }
        catch {
            throw $_
        }
    }
}
