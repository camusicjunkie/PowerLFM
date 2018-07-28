function Get-LFMUserTopTrack {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopTrack')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7day', '1month', 
                     '3month', '6month', '12month')]
        [string] $TimePeriod,
        
        [string] $Limit,
        [string] $Page
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getTopTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
            'TimePeriod' {$apiParams.add('period', $TimePeriod)}
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
        
        foreach ($track in $hash.TopTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'Track' = $track.Name
                'PlayCount' = $track.PlayCount
                'TrackUrl' = $track.url
                'TrackId' = $track.Mbid
                'Artist' = $track.Artist.Name
                'ArtistUrl' = $track.Artist.url
                'ArtistId' = $track.Artist.Mbid
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.TopTrack')
            Write-Output $trackInfo
        }

        #$topAlbumInfo = [pscustomobject] @{
        #    'UserName' = $hash.TopAlbums.'@attr'.User
        #    'AlbumsPerPage' = $hash.TopAlbums.'@attr'.PerPage
        #    'Page' = $hash.TopAlbums.'@attr'.Page
        #    'TotalPages' = $hash.TopAlbums.'@attr'.TotalPages
        #    'TotalAlbums' = $hash.TopAlbums.'@attr'.Total
        #    'TopAlbums' = $topAlbums
        #}
#
        #$topAlbumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.TopAlbum')
        #Write-Output $topAlbumInfo
    }
}