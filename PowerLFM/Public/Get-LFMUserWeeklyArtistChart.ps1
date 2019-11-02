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
