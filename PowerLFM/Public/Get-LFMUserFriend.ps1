function Get-LFMUserFriend {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page,

        [switch] $RecentTracks
    )

    begin {
        $apiParams = @{
            'method' = 'user.getFriends'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
            'RecentTracks' {$apiParams.add('recenttracks', 1)}
        }
    }
    process {
        $apiParams.add('user', $UserName)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl

        foreach ($friend in $irm.Friends.User) {
            $userInfo = @{
                'PSTypeName' = 'PowerLFM.User.Info'
                'UserName' = $friend.Name
                'RealName' = $friend.RealName
                'Url' = $friend.Url
                'Country' = $friend.Country
                'Registered' = ConvertFrom-UnixTime -UnixTime $friend.Registered.UnixTime -Local
                'PlayCount' = [int] $friend.PlayCount
                'PlayLists' = $friend.PlayLists
                'ImageUrl' = $friend.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            if ($RecentTracks) {
                $tracks = foreach ($track in $irm.Friends.User.RecentTrack) {
                    $trackInfo = [pscustomobject] @{
                        'PSTypeName' = 'PowerLFM.User.RecentTracks'
                        'Track' = $track.Name
                        'TrackId' = $track.Mbid
                        'TrackUrl' = $track.Url
                        'Artist' = $track.Artist.Name
                        'ArtistId' = $track.Artist.Mbid
                        'ArtistUrl' = $track.Artist.Url
                        'Album' = $track.Album.Name
                        'AlbumId' = $track.Album.Mbid
                        'AlbumUrl' = $track.Album.Url
                        'ScrobbleTime' = ConvertFrom-UnixTime -UnixTime ($track.'@attr'.Uts) -Local
                    }

                    Write-Output $trackInfo
                }

                $userInfo.add('RecentTracks', $tracks)
            }

            $userInfo = [pscustomobject] $userInfo
            Write-Output $userInfo
        }
    }
}
