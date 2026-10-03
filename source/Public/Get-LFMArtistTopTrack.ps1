function Get-LFMArtistTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Track')]
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
        $irm = Invoke-LFMApiMethod -Method 'artist.getTopTracks' -Parameter $PSBoundParameters

        foreach ($track in $irm.TopTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Track'
                'Track' = $track.Name
                'Id' = $track.Mbid
                'Url' = [uri] $track.Url
                'Listeners' = [int] $track.Listeners
                'PlayCount' = [int] $track.PlayCount
            }

            Write-Output $trackInfo
        }
    }
}
