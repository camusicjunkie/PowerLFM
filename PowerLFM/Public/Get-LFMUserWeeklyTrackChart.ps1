function Get-LFMUserWeeklyTrackChart {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyTrackChart')]
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
            'method' = 'user.getWeeklyTrackChart'
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

        foreach ($track in $irm.WeeklyTrackChart.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.WeeklyTrackChart'
                'Track' = $track.Name
                'Url' = $track.Url
                'Id' = $track.Mbid
                'Artist' = $track.Artist.'#text'
                'ArtistId' = $track.Artist.Mbid
                'PlayCount' = [int] $track.PlayCount
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
                'StartDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyTrackChart.'@attr'.From -Local
                'EndDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyTrackChart.'@attr'.To -Local
            }

            Write-Output $trackInfo
        }
    }
}
