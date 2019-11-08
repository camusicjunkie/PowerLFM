function Get-LFMUserRecentTrack {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.RecentTrack')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $EndDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1,50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getRecentTracks'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'extended' = 1
            'format' = 'json'
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $convertedParams = ConvertTo-LFMParameter $noCommonParams

        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            foreach ($track in $irm.RecentTracks.Track) {
                switch ($track.Loved) {
                    '0' {$loved = 'No'}
                    '1' {$loved = 'Yes'}
                }

                $trackInfo = @{
                    'PSTypeName' = 'PowerLFM.User.RecentTrack'
                    'Track' = $track.Name
                    'Artist' = $track.Artist.Name
                    'Album' = $track.Album.'#text'
                    'Loved' = $loved
                }

                $scrobbleTime = ConvertFrom-UnixTime -UnixTime $track.Date.Uts -Local
                switch ($track.'@attr'.NowPlaying) {
                    $true {$trackInfo.Add('ScrobbleTime', 'Now Playing')}
                    $null {$trackInfo.Add('ScrobbleTime', $scrobbleTime)}
                }

                if ($PSBoundParameters.ContainsKey('EndDate') -and $track.'@attr'.NowPlaying -eq 'true') {
                    $trackInfo = $trackInfo[1]
                }

                $trackInfo = [pscustomobject] $trackInfo
                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
