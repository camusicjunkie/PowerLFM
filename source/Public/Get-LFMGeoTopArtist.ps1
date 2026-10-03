function Get-LFMGeoTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Geo.TopArtists')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Country,

        [Parameter()]
        [ValidateRange(1, 119)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'geo.getTopArtists' -Parameter $PSBoundParameters

        foreach ($artist in $irm.TopArtists.Artist) {
            $artistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Geo.TopArtists'
                'Artist' = $artist.Name
                'Id' = $artist.Mbid
                'Url' = [uri] $artist.Url
                'Listeners' = [int] $artist.Listeners
            }

            Write-Output $artistInfo
        }
    }
}
