function Get-LFMUserLovedTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Track')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getLovedTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('user', $UserName)

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

        foreach ($track in $irm.LovedTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.Track'
                'Track' = $track.Name
                'TrackUrl' = [uri] $track.Url
                'Trackid' = $track.Mbid
                'Artist' = $track.Artist.Name
                'ArtistUrl' = [uri] $track.Artist.Url
                'ArtistId' = $track.Artist.Mbid
                'Date' = ConvertFrom-UnixTime -UnixTime $track.Date.Uts -Local
            }

            Write-Output $trackInfo
        }
    }
}
