function Search-LFMAlbum {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Album.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'album.search' -Parameter $PSBoundParameters

        foreach ($match in $irm.Results.AlbumMatches.Album) {
            $matchInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Search'
                'Album' = $match.Name
                'Artist' = $match.Artist
                'Id' = $match.Mbid
                'Url' = [uri] $match.Url
            }

            Write-Output $matchInfo
        }
    }
}
