function Get-LFMUserTopArtist {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopArtist')]
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
            'method' = 'user.getTopArtists'
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
        
        <#$topAlbums = #>foreach ($artist in $hash.TopArtists.Artist) {
            $artistInfo = [pscustomobject] @{
                'Artist' = $artist.Name
                'PlayCount' = $artist.PlayCount
                'ArtistUrl' = $artist.url
                'ArtistId' = $artist.Mbid
                'ImageUrl' = $artist.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            $artistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Artist')
            Write-Output $artistInfo
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