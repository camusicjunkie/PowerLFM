function Get-LFMTagTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopArtists')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'tag.getTopArtists' -Parameter $PSBoundParameters

        foreach ($artist in $irm.TopArtists.Artist) {
            $artistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopArtists'
                'Artist' = $artist.Name
                'ArtistId' = $artist.Mbid
                'ArtistUrl' = [uri] $artist.Url
                'Rank' = [int] $artist.'@attr'.Rank
            }

            Write-Output $artistInfo
        }
    }
}
