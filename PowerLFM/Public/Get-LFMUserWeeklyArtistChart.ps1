function Get-LFMUserWeeklyArtistChart {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyArtistChart')]
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
            'method' = 'user.getWeeklyArtistChart'
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

        foreach ($artist in $irm.WeeklyArtistChart.Artist) {
            $artistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.WeeklyArtistChart'
                'Artist' = $artist.Name
                'Url' = $artist.Url
                'Id' = $artist.Mbid
                'PlayCount' = [int] $artist.PlayCount
                'StartDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyArtistChart.'@attr'.From -Local
                'EndDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyArtistChart.'@attr'.To -Local
            }

            Write-Output $artistInfo
        }
    }
}
