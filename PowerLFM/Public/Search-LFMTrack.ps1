function Search-LFMTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [ValidateRange(1,50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'track.search'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('track', $Track)

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

        foreach ($match in $irm.Results.TrackMatches.Track) {
            $matchInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Track.Search'
                'Track' = $match.Name
                'Artist' = $match.Artist
                'Id' = $match.Mbid
                'Listeners' = [int] $match.Listeners
                'Url' = [uri] $match.Url
            }

            Write-Output $matchInfo
        }
    }
}
