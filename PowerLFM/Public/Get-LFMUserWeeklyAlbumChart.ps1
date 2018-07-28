function Get-LFMUserWeeklyAlbumChart {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyAlbumChart')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $From,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $To
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getWeeklyAlbumChart'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
            'From' {$apiParams.add('from', $From)}
            'To' {$apiParams.add('to', $To)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable
         
        foreach ($album in $hash.WeeklyAlbumChart.Album) {
            $albumInfo = [pscustomobject] @{
                'Album' = $album.Name
                'Url' = $album.Url
                'Id' = $album.Mbid
                'Artist' = $album.Artist.'#text'
                'ArtistId' = $album.Artist.Mbid
                'PlayCount' = $album.PlayCount
                'From' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyAlbumChart.'@attr'.From -Local
                'To' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyAlbumChart.'@attr'.To -Local
            }

            $albumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.WeeklyChartList')
            Write-Output $albumInfo
        }
    }
}
