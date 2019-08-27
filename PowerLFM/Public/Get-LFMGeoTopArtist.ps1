function Get-LFMGeoTopArtist {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Geo.TopArtists')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Country,

        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'geo.getTopArtists'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('country', $Country)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl

        foreach ($artist in $irm.TopArtists.Artist) {
            $artistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Geo.TopArtists'
                'Artist' = $artist.Name
                'Id' = $artist.Mbid
                'Url' = $artist.Url
                'Listeners' = [int] $artist.Listeners
                'ImageUrl' = $artist.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            Write-Output $artistInfo
        }
    }
}
