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
        [ValidateRange(1,50)]
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

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('track', $Track)
        $apiParams.Add('artist', $Artist)

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

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
}
