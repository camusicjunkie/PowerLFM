function Search-LFMArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Artist.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'artist.search' -Parameter $PSBoundParameters

        foreach ($match in $irm.Results.ArtistMatches.Artist) {
            $matchInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Search'
                'Artist' = $match.Name
                'Id' = $match.Mbid
                'Listeners' = [int] $match.Listeners
                'Url' = [uri] $match.Url
            }

            Write-Output $matchInfo
        }
    }
}
