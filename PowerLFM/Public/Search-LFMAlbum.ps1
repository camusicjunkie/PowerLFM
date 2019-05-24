function Search-LFMAlbum {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Album.Search')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
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
        $apiParams.add('album', $Album)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

        foreach ($match in $irm.Results.AlbumMatches.Album) {
            $matchInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Search'
                'Album' = $match.Name
                'Artist' = $match.Artist
                'Id' = $match.Mbid
                'Url' = $match.Url
            }

            Write-Output $matchInfo
        }
    }
}
