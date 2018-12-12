function Get-LFMArtistSimilar {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Similar')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'artist')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $Limit = '5',
        [switch] $AutoCorrect
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'artist.getSimilar'
            'api_key' = $LFMConfig.APIKey
            'limit' = $Limit
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'artist') {
            $apiParams.add('artist', $Artist)
        }
        if ($PSCmdlet.ParameterSetName -eq 'id') {
            $apiParams.add('mbid', $Id)
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
