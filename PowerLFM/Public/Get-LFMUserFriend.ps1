function Get-LFMUserFriend {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.Friend')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page,
        [switch] $RecentTracks
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getFriends'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
            'RecentTracks' {$apiParams.add('recenttracks', 1)}
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable

        $users = foreach ($friend in $hash.Friends.User) {
            $userInfo = [pscustomobject] @{
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
                $tracks = foreach ($track in $hash.Friends.User.RecentTrack) {
                    $trackInfo = [pscustomobject] @{
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

                    $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.RecentTracks')
                    Write-Output $trackInfo
                }

                $userInfo | Add-Member -MemberType NoteProperty -Name 'RecentTracks' -Value $tracks
            }

            $userInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Info')
            Write-Output $userInfo
        }

        $friendInfo = [pscustomobject] @{
            'UserName' = $hash.Friends.'@attr'.For
            'FriendsPerPage' = $hash.Friends.'@attr'.PerPage
            'Page' = $hash.Friends.'@attr'.Page
            'TotalPages' = $hash.Friends.'@attr'.TotalPages
            'TotalFriends' = $hash.Friends.'@attr'.Total
            'Friends' = $users
        }

        $friendInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Friend')
        Write-Output $friendInfo
    }
}
