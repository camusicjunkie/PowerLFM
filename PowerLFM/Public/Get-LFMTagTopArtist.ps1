function Get-LFMTagTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopArtists')]
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
            'method' = 'tag.getTopArtists'
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
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

        foreach ($artist in $irm.TopArtists.Artist) {
            $artistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopArtists'
                'Artist' = $artist.Name
                'ArtistId' = $artist.Mbid
                'ArtistUrl' = [uri] $artist.Url
                'Rank' = [int] $artist.'@attr'.Rank
            }

            Write-Output $artistInfo
        }
    }
}
