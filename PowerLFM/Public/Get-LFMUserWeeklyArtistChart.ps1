function Get-LFMUserWeeklyArtistChart {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyArtistChart')]
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
        $apiParams = [ordered] @{
            'method' = 'user.getWeeklyArtistChart'
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

        foreach ($artist in $hash.WeeklyArtistChart.Artist) {
            $artistInfo = [pscustomobject] @{
                'Artist' = $artist.Name
                'Url' = $artist.Url
                'Id' = $artist.Mbid
                'PlayCount' = [int] $artist.PlayCount
                'StartDate' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyArtistChart.'@attr'.From -Local
                'EndDate' = ConvertFrom-UnixTime -UnixTime $hash.WeeklyArtistChart.'@attr'.To -Local
            }

            $artistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.WeeklyArtistChart')
            Write-Output $artistInfo
        }
    }
}
