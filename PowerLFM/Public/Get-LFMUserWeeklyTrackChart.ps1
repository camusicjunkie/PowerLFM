function Get-LFMUserWeeklyTrackChart {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyTrackChart')]
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
            'method' = 'user.getWeeklyTrackChart'
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
         
        foreach ($track in $hash.WeeklyTrackChart.Track) {
            $trackInfo = [pscustomobject] @{
                'Track' = $track.Name
                'Url' = $track.Url
                'Id' = $track.Mbid
                'Artist' = $track.Artist.'#text'
                'ArtistId' = $track.Artist.Mbid
                'PlayCount' = $track.PlayCount
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
                'From' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyTrackChart.'@attr'.From -Local
                'To' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyTrackChart.'@attr'.To -Local
            }

            $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.WeeklyTrackChart')
            Write-Output $trackInfo
        }
    }
}