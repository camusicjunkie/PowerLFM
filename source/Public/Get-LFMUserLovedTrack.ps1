function Get-LFMUserLovedTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Track')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'user.getLovedTracks' -Parameter $PSBoundParameters

        foreach ($track in $irm.LovedTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.Track'
                'Track' = $track.Name
                'TrackUrl' = [uri] $track.Url
                'TrackId' = $track.Mbid
                'Artist' = $track.Artist.Name
                'ArtistUrl' = [uri] $track.Artist.Url
                'ArtistId' = $track.Artist.Mbid
                'Date' = ConvertFrom-UnixTime -UnixTime $track.Date.Uts -Local
            }

            Write-Output $trackInfo
        }
    }
}
