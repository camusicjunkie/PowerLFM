function Search-LFMTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Track,

        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'track.search'
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
            'Track' {$apiParams.add('track', $Track)}
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

        $trackMatches = foreach ($match in $hash.Results.TrackMatches.Track) {
            $matchInfo = [pscustomobject] @{
                'Track' = $match.Name
                'Artist' = $match.Artist
                'Id' = $match.Mbid
                'Listeners' = [int] $match.Listeners
                'Url' = $match.Url
            }
            $matchInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Track.Match')
            Write-Output $matchInfo
        }

        $trackSearchInfo = [pscustomobject] @{
            'SearchTerm' = $Track
            'MatchesPerPage' = $hash.Results.'OpenSearch:ItemsPerPage'
            'TotalMatches' = $hash.Results.'OpenSearch:TotalResults'
            'TrackMatches' = $TrackMatches
        }

        $trackSearchInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Track.Search')
        Write-Output $trackSearchInfo
    }
}
