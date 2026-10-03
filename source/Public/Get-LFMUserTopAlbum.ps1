function Get-LFMUserTopAlbum {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopAlbum')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7 Days', '1 Month',
                     '3 Months', '6 Months', '1 Year')]
        [string] $TimePeriod,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'user.getTopAlbums' -Parameter $PSBoundParameters

        foreach ($album in $irm.TopAlbums.Album) {
            $albumInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.Album'
                'Album' = $album.Name
                'PlayCount' = [int] $album.PlayCount
                'AlbumUrl' = [uri] $album.Url
                'AlbumId' = $album.Mbid
                'Artist' = $album.Artist.Name
                'ArtistUrl' = [uri] $album.Artist.Url
                'ArtistId' = $album.Artist.Mbid
            }

            Write-Output $albumInfo
        }
    }
}
