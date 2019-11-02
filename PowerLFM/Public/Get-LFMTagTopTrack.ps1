function Get-LFMTagTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTracks')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'tag.getTopTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('tag', $Tag)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl
            if ($irm.Error) {Write-Output $irm; return}

            foreach ($track in $irm.Tracks.Track) {
                $trackInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Tag.TopTracks'
                    'Track' = $track.Name
                    'TrackId' = $track.Mbid
                    'TrackUrl' = [uri] $track.Url
                    'Artist' = $track.Artist.Name
                    'ArtistId' = $track.Artist.Mbid
                    'ArtistUrl' = [uri] $track.Artist.Url
                    'Rank' = [int] $track.'@attr'.Rank
                    'Duration' = [int] $track.Duration
                }

                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
