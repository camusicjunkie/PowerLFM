function Get-LFMGeoTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Geo.TopTracks')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Country,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $City,

        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'geo.getTopTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('country', $Country)

        switch ($PSBoundParameters.Keys) {
            'City' {$apiParams.Add('location', $City)}
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

        foreach ($track in $irm.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Geo.TopTracks'
                'Track' = $track.Name
                'TrackId' = $track.Mbid
                'TrackUrl' = [uri] $track.Url
                'Artist' = $track.Artist.Name
                'ArtistId' = $track.Artist.Mbid
                'ArtistUrl' = [uri] $track.Artist.Url
                'Rank' = [int] $track.'@attr'.Rank
                'Listeners' = [int] $track.Listeners
            }

            Write-Output $trackInfo
        }
    }
}
