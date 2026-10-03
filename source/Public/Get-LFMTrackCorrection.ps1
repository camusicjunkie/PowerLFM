function Get-LFMTrackCorrection {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.Correction')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'track.getCorrection' -Parameter $PSBoundParameters

        $correction = $irm.Corrections.Correction.Track
        $correctedTrackInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Track.Correction'
            'Track' = $correction.Name
            'TrackUrl' = [uri] $correction.Url
            'Artist' = $correction.Artist.Name
            'ArtistUrl' = [uri] $correction.Artist.Url
            'ArtistId' = $correction.Artist.Mbid
        }

        Write-Output $correctedTrackInfo
    }
}
