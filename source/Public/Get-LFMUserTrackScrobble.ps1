function Get-LFMUserTrackScrobble {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TrackScrobble')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'user.getTrackScrobbles' -Parameter $PSBoundParameters

        foreach ($scrobble in $irm.TrackScrobbles.Track) {
            $scrobbleInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.TrackScrobble'
                'Track' = $scrobble.Name
                'TrackId' = $scrobble.Mbid
                'TrackUrl' = $scrobble.Url
                'Artist' = $scrobble.Artist.'#text'
                'Album' = $scrobble.Album.'#text'
                'Date' = ConvertFrom-UnixTime -UnixTime $scrobble.Date.Uts -Local
            }

            Write-Output $scrobbleInfo
        }
    }
}
