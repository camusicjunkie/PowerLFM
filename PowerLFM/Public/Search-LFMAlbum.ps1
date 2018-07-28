function Search-LFMAlbum {
    [CmdletBinding()]
    [OutputType('PowerLFM.Album.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Album,
        
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'album.search'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
        
        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'Album' {$apiParams.add('album', $Album)}
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
        
        $albumMatches = foreach ($match in $hash.Results.AlbumMatches.Album) {
            $matchInfo = [pscustomobject] @{
                'Album' = $match.Name
                'Id' = $match.Mbid
                'Url' = $match.Url
                'Listeners' = $match.Listeners
            }
            $matchInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Match')
            Write-Output $matchInfo
        }

        $albumSearchInfo = [pscustomobject] @{
            'SearchTerm' = $hash.Results.'OpenSearch:Query'.SearchTerms
            'MatchesPerPage' = $hash.Results.'OpenSearch:ItemsPerPage'
            'TotalMatches' = $hash.Results.'OpenSearch:TotalResults'
            'ArtistMatches' = $albumMatches
        }

        $albumSearchInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Search')
        Write-Output $albumSearchInfo
    }
}