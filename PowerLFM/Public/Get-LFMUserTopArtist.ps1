function Get-LFMUserTopArtist {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopArtist')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7day', '1month',
                     '3month', '6month', '12month')]
        [string] $TimePeriod,

        [string] $Limit,
        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'user.getTopArtists'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
            'TimePeriod' {$apiParams.add('period', $TimePeriod)}
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
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

        foreach ($artist in $hash.TopArtists.Artist) {
            $artistInfo = [pscustomobject] @{
                'Artist' = $artist.Name
                'PlayCount' = [int] $artist.PlayCount
                'Url' = $artist.url
                'Id' = $artist.Mbid
                'ImageUrl' = $artist.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            $artistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Artist')
            Write-Output $artistInfo
        }
    }
}
