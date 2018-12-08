function Get-LFMUserWeeklyTrackChart {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyTrackChart')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $EndDate
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getWeeklyTrackChart'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
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
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable

        foreach ($track in $hash.WeeklyTrackChart.Track) {
            $trackInfo = [pscustomobject] @{
                'Track' = $track.Name
                'Url' = $track.Url
                'Id' = $track.Mbid
                'Artist' = $track.Artist.'#text'
                'ArtistId' = $track.Artist.Mbid
                'PlayCount' = [int] $track.PlayCount
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
                'StartDate' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyTrackChart.'@attr'.From -Local
                'EndDate' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyTrackChart.'@attr'.To -Local
            }

            $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.WeeklyTrackChart')
            Write-Output $trackInfo
        }
    }
}
