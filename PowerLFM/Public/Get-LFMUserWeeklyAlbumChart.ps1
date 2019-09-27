function Get-LFMUserWeeklyAlbumChart {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyAlbumChart')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $EndDate,

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
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
        }

        switch ($PSBoundParameters.Keys) {
            'StartDate' {$apiParams.Add('from', (ConvertTo-UnixTime -Date $StartDate))}
            'EndDate' {$apiParams.Add('to', (ConvertTo-UnixTime -Date $EndDate))}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

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
}
