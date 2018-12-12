function Get-LFMUserArtistTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.ArtistTrack')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $EndDate,
        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'user.getArtistTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        if ($PSBoundParameters.Keys -clike '*Date') {
            $unixStartTime = ConvertTo-UnixTime -Date $StartDate
            $unixEndTime = ConvertTo-UnixTime -Date $EndDate

            $apiParams.add('startTimestamp', $unixStartTime)
            $apiParams.add('endTimestamp', $unixEndTime)
        }

        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
            'Artist' {$apiParams.add('artist', $Artist)}
            'Page' {$apiParams.add('page', $Page)}
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

        $tracks = foreach ($track in $hash.ArtistTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'Track' = $track.Name
                'Id' = $track.Mbid
                'Url' = $track.Url
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
                'Album' = $track.Album.'#text'
                'ScrobbleTime' = ConvertFrom-UnixTime -UnixTime ($track.Date.Uts) -Local
            }
            $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Track')
            Write-Output $trackInfo
        }

        if ($null -eq $tracks) {
            Write-Verbose 'No tracks were scrobbled during this time'
        }

        $trackArtist = $hash.ArtistTracks.'@attr'.Artist
        $tcTrackArtist = ConvertTo-TitleCase -String $trackArtist
        $userArtistTrackInfo = [pscustomobject] @{
            'Artist' = $tcTrackArtist
            'UserName' = $hash.ArtistTracks.'@attr'.User
            'Tracks' = $tracks
        }

        $userArtistTrackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.ArtistTrack')
        Write-Output $userArtistTrackInfo
    }
}
