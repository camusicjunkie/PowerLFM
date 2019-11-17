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

    begin {
        $apiParams = @{
            'method' = 'user.getTrackScrobbles'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $convertedParams = ConvertTo-LFMParameter $noCommonParams

        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            foreach ($scrobble in $irm.TrackScrobbles.Track) {
                [PSCustomObject] @{
                    'Track' = $scrobble.Name
                    'TrackId' = $scrobble.Mbid
                    'TrackUrl' = $scrobble.Url
                    'Artist' = $scrobble.Artist.'#text'
                    'Album' = $scrobble.Album.'#text'
                    'Date' = ConvertFrom-UnixTime -UnixTime $scrobble.Date.Uts -Local
                }
            }
        }
        catch {
            throw $_
        }
    }
}
