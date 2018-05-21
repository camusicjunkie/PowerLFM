function Get-LFMArtistTopAlbum {
    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.TopAlbum')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'artist')]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $Limit = '5',
        [string] $Page,
        [switch] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.getTopAlbums'
            'api_key' = $LFMConfig.APIKey
            'limit' = $Limit
            'format' = 'json'
        }
    }
    process {
        #Adding key/value to hashtable based off ParameterSetName
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.add('artist', $Artist)}
            'id' {$apiParams.add('mbid', $Id)}
        }

        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
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
        $iwr = Invoke-WebRequest -Uri $apiUrl
        $jsonString = $iwr.AllElements[3].innerHTML
        $hash = $jsonString | ConvertFrom-Json | ConvertTo-HashTable
        
        $albums = foreach ($album in $hash.TopAlbums.Album) {
            $albumInfo = [pscustomobject] @{
                'Album' = $album.TopAlbums.Album.Name
                'Id' = $album.TopAlbums.Album.Mbid
                'Url' = $album.TopAlbums.Album.Url
                'PlayCount' = $album.TopAlbums.Album.PlayCount
            }
            $albumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Album')
            Write-Output $albumInfo
        }

        $topAlbumInfo = [pscustomobject] @{
            'Artist' = $album.TopAlbums.'@attr'.Artist
            'AlbumsPerPage' = $album.TopAlbums.'@attr'.PerPage
            'Page' = $album.TopAlbums.'@attr'.Page
            'TotalPages' = $album.TopAlbums.'@attr'.TotalPages
            'TotalAlbums' = $album.TopAlbums.'@attr'.Total
            'Albums' = $albums
        }

        $topAlbumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.TopAlbum')
        Write-Output $topAlbumInfo
    }
}