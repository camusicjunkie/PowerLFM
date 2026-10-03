function Search-LFMTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'track.search' -Parameter $PSBoundParameters

        foreach ($match in $irm.Results.TrackMatches.Track) {
            $matchInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Track.Search'
                'Track' = $match.Name
                'Artist' = $match.Artist
                'Id' = $match.Mbid
                'Listeners' = [int] $match.Listeners
                'Url' = [uri] $match.Url
            }

            Write-Output $matchInfo
        }
    }
}
