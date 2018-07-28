function Search-LFMArtist {
    [CmdletBinding()]
    [OutputType('PowerLFM.Artist.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,
        
        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.search'
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
            'Artist' {$apiParams.add('artist', $Artist)}
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
        
        $artistMatches = foreach ($match in $hash.Results.ArtistMatches.Artist) {
            $matchInfo = [pscustomobject] @{
                'Artist' = $match.Name
                'Id' = $match.Mbid
                'Url' = $match.Url
                'Listeners' = $match.Listeners
            }
            $matchInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Match')
            Write-Output $matchInfo
        }

        $artistSearchInfo = [pscustomobject] @{
            'SearchTerm' = $hash.Results.'OpenSearch:Query'.SearchTerms
            'MatchesPerPage' = $hash.Results.'OpenSearch:ItemsPerPage'
            'TotalMatches' = $hash.Results.'OpenSearch:TotalResults'
            'ArtistMatches' = $artistMatches
        }

        $artistSearchInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Search')
        Write-Output $artistSearchInfo
    }
}