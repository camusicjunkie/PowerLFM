function Get-LFMUserWeeklyAlbumChart {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyAlbumChart')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $EndDate
    )

    begin {
        $apiParams = @{
            'method' = 'user.getWeeklyAlbumChart'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $apiParams.add('user', $UserName)

        switch ($PSBoundParameters.Keys) {
            'StartDate' {$apiParams.add('from', (ConvertTo-UnixTime -Date $StartDate))}
            'EndDate' {$apiParams.add('to', (ConvertTo-UnixTime -Date $EndDate))}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
            if ($irm.error) {
                [pscustomobject] @{
                    'Error' = $irm.error
                    'Message' = $irm.message
                }
                return
            }
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

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
