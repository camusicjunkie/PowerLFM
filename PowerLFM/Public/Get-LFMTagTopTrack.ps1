function Get-LFMTagTopTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTracks')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Tag,

        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'tag.getTopTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        $apiParams.add('tag', $Tag)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl

        foreach ($track in $irm.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopTracks'
                'Track' = $track.Name
                'TrackId' = $track.Mbid
                'TrackUrl' = $track.Url
                'Artist' = $track.Artist.Name
                'ArtistId' = $track.Artist.Mbid
                'ArtistUrl' = $track.Artist.Url
                'Rank' = $track.'@attr'.Rank
                'Duration' = $track.Duration
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            Write-Output $trackInfo
        }
    }
}