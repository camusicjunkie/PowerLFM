function Get-LFMUserTopTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopTrack')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7 Days', '1 Month',
                     '3 Months', '6 Months', '1 Year')]
        [string] $TimePeriod,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getTopTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        $period = @{
            'Overall' = 'overall'
            '7 Days' = '7days'
            '1 Month' = '1month'
            '3 Months' = '3month'
            '6 Months' = '6month'
            '1 Year' = '12month'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
            'TimePeriod' {$apiParams.Add('period', $period[$TimePeriod])}
        }
    }
    process {
        $apiParams.Add('user', $UserName)

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

        foreach ($track in $irm.TopTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.TopTrack'
                'Track' = $track.Name
                'PlayCount' = [int] $track.PlayCount
                'TrackUrl' = [uri] $track.Url
                'TrackId' = $track.Mbid
                'Artist' = $track.Artist.Name
                'ArtistUrl' = [uri] $track.Artist.Url
                'ArtistId' = $track.Artist.Mbid
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            Write-Output $trackInfo
        }
    }
}
