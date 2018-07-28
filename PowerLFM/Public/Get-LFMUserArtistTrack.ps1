function Get-LFMUserArtistTrack {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.ArtistTrack')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(ParameterSetName = 'date')]
        [datetime] $StartDate,

        [Parameter(ParameterSetName = 'date')]
        [datetime] $EndDate,
        [string] $Page
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getArtistTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        if ($PSCmdlet.ParameterSetName -eq 'date') {
            $unixStartTime = ConvertTo-UnixTime -Date $StartDate
            $unixEndTime = ConvertTo-UnixTime -Date $EndDate

            $apiParams.add('startTimestamp', $unixStartTime)
            $apiParams.add('endTimestamp', $unixEndTime)
        }
    }
    process {
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
            Write-Warning 'Something went wrong with the Last.fm API'
            Write-Warning 'The artist tracks were not populated.'
            Write-Warning 'Please try again.'
            break
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