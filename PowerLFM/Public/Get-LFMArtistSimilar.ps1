function Get-LFMArtistSimilar {
    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Similar')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'artist')]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $Limit = '5',
        [switch] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.getSimilar'
            'api_key' = $LFMConfig.APIKey
            'limit' = $Limit
            'format' = 'json'
        }
    }
    process {
        #Adding key/value to hashtable based off ParameterSetName
        if ($PSCmdlet.ParameterSetName -eq 'artist') {
            $apiParams.add('artist', $Artist)
        }
        if ($PSCmdlet.ParameterSetName -eq 'id') {
            $apiParams.add('mbid', $Id)
        }
        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
        
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $iwr = Invoke-WebRequest -Uri $apiUrl
        $jsonString = $iwr.AllElements[3].innerHTML
        $hash = $jsonString | ConvertFrom-Json | ConvertTo-HashTable

        foreach ($similar in $hash.SimilarArtists.Artist) {
            $similarInfo = [pscustomobject] @{
                'Artist' = $similar.Name
                'Id' = $similar.Mbid
                'Url' = $similar.Url
                'Match' = $similar.Match
            }
            $similarInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Similar')
            Write-Output $similarInfo
        }
    }
}