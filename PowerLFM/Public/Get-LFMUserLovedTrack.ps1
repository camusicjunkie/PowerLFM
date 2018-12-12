function Get-LFMUserLovedTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.LovedTrack')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'user.getLovedTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
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

        $lovedTracks = foreach ($track in $hash.LovedTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'Track' = $track.Name
                'TrackUrl' = $track.Url
                'Trackid' = $track.Mbid
                'Artist' = $track.Artist.Name
                'ArtistUrl' = $track.Artist.url
                'ArtistId' = $track.Artist.Mbid
                'Date' = ConvertFrom-UnixTime -UnixTime $track.Date.Uts -Local
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Track')
            Write-Output $trackInfo
        }

        $lovedTrackInfo = [pscustomobject] @{
            'UserName' = $hash.LovedTracks.'@attr'.User
            'TracksPerPage' = $hash.LovedTracks.'@attr'.PerPage
            'Page' = $hash.LovedTracks.'@attr'.Page
            'TotalPages' = $hash.LovedTracks.'@attr'.TotalPages
            'TotalTracks' = $hash.LovedTracks.'@attr'.Total
            'LovedTracks' = $lovedTracks
        }

        $lovedTrackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.LovedTrack')
        Write-Output $lovedTrackInfo
    }
}
