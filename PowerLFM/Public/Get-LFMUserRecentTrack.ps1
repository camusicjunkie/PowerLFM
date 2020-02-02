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
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getRecentTracks'
            'api_key' = $script:LFMConfig.APIKey
            'sk' = $script:LFMConfig.SessionKey
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

            $i = 0
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

                # This prevents a track that is currently playing from being displayed when
                # an end date is specified because the tracks should only be in the past.
                if ($PSBoundParameters.ContainsKey('EndDate') -and $track.'@attr'.NowPlaying -eq 'true') {
                    $trackInfo = $trackInfo[1]
                }

                # This prevents more tracks in the output than specified with the limit
                # parameter when a track is currently playing. Previously, if the limit
                # was set to two there would be three objects in the output including
                # the currently playing track.
                if ($irm.RecentTracks.Track[0].'@attr'.NowPlaying -and
                    $PSBoundParameters.ContainsKey('Limit') -and
                    $Limit -eq $i) {
                    break
                }
                $i++

                $trackInfo = [pscustomobject] $trackInfo
                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
