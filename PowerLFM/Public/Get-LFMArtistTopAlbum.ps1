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
        
        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page,
        [switch] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.getTopAlbums'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        #Adding key/value to hashtable based off ParameterSetName
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.add('artist', $Artist)}
            'id' {$apiParams.add('mbid', $Id)}
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
        
        $albums = foreach ($album in $hash.TopAlbums.Album) {
            $albumInfo = [pscustomobject] @{
                'Album' = $album.Name
                'Id' = $album.Mbid
                'Url' = $album.Url
                'PlayCount' = $album.PlayCount
            }
            $albumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Album')
            Write-Output $albumInfo
        }

        $topAlbumInfo = [pscustomobject] @{
            'Artist' = $hash.TopAlbums.'@attr'.Artist
            'AlbumsPerPage' = $hash.TopAlbums.'@attr'.PerPage
            'Page' = $hash.TopAlbums.'@attr'.Page
            'TotalPages' = $hash.TopAlbums.'@attr'.TotalPages
            'TotalAlbums' = $hash.TopAlbums.'@attr'.Total
            'Albums' = $albums
        }

        $topAlbumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.TopAlbum')
        Write-Output $topAlbumInfo
    }
}