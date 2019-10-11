function Search-LFMArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Artist.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter()]
        [ValidateRange(1,50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'artist.search'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('artist', $Artist)

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

        foreach ($match in $irm.Results.ArtistMatches.Artist) {
            $matchInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Search'
                'Artist' = $match.Name
                'Id' = $match.Mbid
                'Listeners' = [int] $match.Listeners
                'Url' = [uri] $match.Url
            }

            Write-Output $matchInfo
        }
    }
}
