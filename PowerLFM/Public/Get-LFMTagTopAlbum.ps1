function Get-LFMTagTopAlbum {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopAlbums')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'tag.getTopAlbums'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('tag', $Tag)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            foreach ($album in $irm.Albums.Album) {
                $albumInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Tag.TopAlbums'
                    'Album' = $album.Name
                    'AlbumId' = $album.Mbid
                    'AlbumUrl' = [uri] $album.Url
                    'Artist' = $album.Artist.Name
                    'ArtistId' = $album.Artist.Mbid
                    'ArtistUrl' = [uri] $album.Artist.Url
                    'Rank' = [int] $album.'@attr'.Rank
                }

                Write-Output $albumInfo
            }
        }
        catch {
            throw $_
        }
    }
}
