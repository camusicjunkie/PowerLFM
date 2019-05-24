function Get-LFMTagTopArtist {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopArtists')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'tag.getTopArtists'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        $apiParams.add('tag', $Tag)

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

        foreach ($artist in $irm.TopArtists.Artist) {
            $artistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopArtists'
                'Artist' = $artist.Name
                'ArtistId' = $artist.Mbid
                'ArtistUrl' = $artist.Url
                'Rank' = $artist.'@attr'.rank
                'ImageUrl' = $artist.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            Write-Output $artistInfo
        }
    }
}
