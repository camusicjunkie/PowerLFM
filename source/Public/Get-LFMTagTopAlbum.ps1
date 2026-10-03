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

    process {
        $irm = Invoke-LFMApiMethod -Method 'tag.getTopAlbums' -Parameter $PSBoundParameters

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
}
