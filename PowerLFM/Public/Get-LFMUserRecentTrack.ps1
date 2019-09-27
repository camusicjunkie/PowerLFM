function Get-LFMUserRecentTrack {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.RecentTrack')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
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
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
        }

        switch ($PSBoundParameters.Keys) {
            'StartDate' {$apiParams.Add('from', (ConvertTo-UnixTime -Date $StartDate))}
            'EndDate' {$apiParams.Add('to', (ConvertTo-UnixTime -Date $EndDate))}
            'Extended' {$apiParams.Add('extended', 1)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

        foreach ($track in $irm.RecentTracks.Track) {
            $trackInfo = @{
                'PSTypeName' = 'PowerLFM.User.RecentTrack'
                'Track' = $track.Name
                'Artist' = $track.Artist.'#text'
                'Album' = $track.Album.'#text'
            }

            $scrobbleTime = ConvertFrom-UnixTime -UnixTime $track.Date.Uts -Local
            switch ($track.'@attr'.NowPlaying) {
                $true {$trackInfo.Add('NowPlaying', $true);
                       $trackInfo.Add('ScrobbleTime', $null)}
                $null {$trackInfo.Add('NowPlaying', $null);
                       $trackInfo.Add('ScrobbleTime', $scrobbleTime)}
            }

            if ($Extended) {
                switch ($track.Loved) {
                    '0' {$loved = 'No'}
                    '1' {$loved = 'Yes'}
                }

                $trackInfo.Remove('Artist')
                $trackInfo.Add('Artist', $track.Artist.Name)
                $trackInfo.Add('Loved', $loved)
            }

            $trackInfo = [pscustomobject] $trackInfo
            Write-Output $trackInfo
        }
    }
}
