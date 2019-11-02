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
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'StartDate' {$apiParams.Add('from', (ConvertTo-UnixTime -Date $StartDate))}
            'EndDate' {$apiParams.Add('to', (ConvertTo-UnixTime -Date $EndDate))}
        }

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
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
            $irm = Invoke-LFMApiUri -Uri $apiUrl
            if ($irm.Error) {Write-Output $irm; return}

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
