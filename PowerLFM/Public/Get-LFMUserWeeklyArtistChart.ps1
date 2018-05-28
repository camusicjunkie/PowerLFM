function Get-LFMUserWeeklyArtistChart {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyArtistChart')]
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
            'method' = 'user.getWeeklyArtistChart'
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
        $iwr = Invoke-WebRequest -Uri $apiUrl
        $jsonString = $iwr.AllElements[3].innerHTML
        $hash = $jsonString | ConvertFrom-Json | ConvertTo-HashTable
         
        foreach ($artist in $hash.WeeklyArtistChart.Artist) {
            $artistInfo = [pscustomobject] @{
                'Artist' = $artist.Name
                'Url' = $artist.Url
                'Id' = $artist.Mbid
                'PlayCount' = $artist.PlayCount
                'From' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyArtistChart.'@attr'.From -Local
                'To' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyArtistChart.'@attr'.To -Local
            }

            $artistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.WeeklyArtistChart')
            Write-Output $artistInfo
        }
    }
}