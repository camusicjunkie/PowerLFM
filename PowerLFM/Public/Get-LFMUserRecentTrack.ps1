function Get-LFMUserRecentTrack {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.RecentTrack')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $EndDate,

        [Parameter()]
        [switch] $Extended,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getRecentTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        $apiParams.add('user', $UserName)

        switch ($PSBoundParameters.Keys) {
            'StartDate' {$apiParams.add('from', (ConvertTo-UnixTime -Date $StartDate))}
            'EndDate' {$apiParams.add('to', (ConvertTo-UnixTime -Date $EndDate))}
            'Extended' {$apiParams.add('extended', 1)}
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
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

        foreach ($track in $irm.RecentTracks.Track) {
            $trackInfo = @{
                'PSTypeName' = 'PowerLFM.User.RecentTrack'
                'Track' = $track.Name
                'Artist' = $track.Artist.'#text'
                'Album' = $track.Album.'#text'
            }

            $scrobbleTime = ConvertFrom-UnixTime -UnixTime $track.Date.Uts -Local
            switch ($track.'@attr'.NowPlaying) {
                $true {$trackInfo.add('NowPlaying', $true);
                       $trackInfo.add('ScrobbleTime', $null)}
                $null {$trackInfo.add('NowPlaying', $null);
                       $trackInfo.add('ScrobbleTime', $scrobbleTime)}
            }

            if ($Extended) {
                switch ($track.Loved) {
                    '0' {$loved = 'No'}
                    '1' {$loved = 'Yes'}
                }

                $trackInfo.remove('Artist')
                $trackInfo.add('Artist', $track.Artist.Name)
                $trackInfo.add('Loved', $loved)
            }

            $trackInfo = [pscustomobject] $trackInfo
            Write-Output $trackInfo
        }
    }
}
