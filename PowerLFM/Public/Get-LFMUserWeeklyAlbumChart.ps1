function Get-LFMUserWeeklyAlbumChart {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyAlbumChart')]
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
            'method' = 'user.getWeeklyAlbumChart'
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

            foreach ($album in $irm.WeeklyAlbumChart.Album) {
                $albumInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.WeeklyChartList'
                    'Album' = $album.Name
                    'Url' = [uri] $album.Url
                    'Id' = $album.Mbid
                    'Artist' = $album.Artist.'#text'
                    'ArtistId' = $album.Artist.Mbid
                    'PlayCount' = [int] $album.PlayCount
                    'StartDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyAlbumChart.'@attr'.From -Local
                    'EndDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyAlbumChart.'@attr'.To -Local
                }

                Write-Output $albumInfo
            }
        }
        catch {
            throw $_
        }
    }
}
