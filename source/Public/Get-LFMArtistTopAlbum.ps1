function Get-LFMArtistTopAlbum {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Album')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'artist')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page,

        [switch] $AutoCorrect
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'artist.getTopAlbums' -Parameter $PSBoundParameters

        foreach ($album in $irm.TopAlbums.Album) {
            $albumInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Album'
                'Album' = $album.Name
                'Id' = $album.Mbid
                'Url' = [uri]$album.Url
                'PlayCount' = [int] $album.PlayCount
            }

            Write-Output $albumInfo
        }
    }
}
