function Get-LFMGeoTopTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Geo.TopTracks')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string] $Country,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $City,

        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'geo.getTopTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'Country' {$apiParams.add('country', $Country)}
            'City' {$apiParams.add('location', $City)}
        }
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable

        foreach ($track in $hash.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'Track' = $track.Name
                'TrackId' = $track.Mbid
                'TrackUrl' = $track.Url
                'Artist' = $track.Artist.Name
                'ArtistId' = $track.Artist.Mbid
                'ArtistUrl' = $track.Artist.Url
                'Rank' = $track.'@attr'.rank
                'Listeners' = [int] $track.Listeners
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Geo.TopTracks')
            Write-Output $trackInfo
        }
    }
}
