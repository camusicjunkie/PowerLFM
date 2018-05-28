function Get-LFMUserTopAlbum {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopAlbum')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7day', '1month', 
                     '3month', '6month', '12month')]
        [string] $TimePeriod,
        
        [Parameter()]
        #[ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getTopAlbums'
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
        $iwr = Invoke-WebRequest -Uri $apiUrl
        $jsonString = $iwr.AllElements[3].innerHTML
        $hash = $jsonString | ConvertFrom-Json | ConvertTo-HashTable
         
        <#$topAlbums = #>foreach ($album in $hash.TopAlbums.Album) {
            $albumInfo = [pscustomobject] @{
                'Album' = $album.Name
                'PlayCount' = $album.PlayCount
                'AlbumUrl' = $album.Url
                'Albumid' = $album.Mbid
                'Artist' = $album.Artist.Name
                'ArtistUrl' = $album.Artist.url
                'ArtistId' = $album.Artist.Mbid
                'ImageUrl' = $album.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            $albumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Album')
            Write-Output $albumInfo
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