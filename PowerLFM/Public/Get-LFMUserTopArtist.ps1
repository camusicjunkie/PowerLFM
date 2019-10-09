function Get-LFMUserTopArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopArtist')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7 Days', '1 Month',
                     '3 Months', '6 Months', '1 Year')]
        [string] $TimePeriod,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getTopArtists'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }

        $period = @{
            'Overall' = 'overall'
            '7 Days' = '7days'
            '1 Month' = '1month'
            '3 Months' = '3month'
            '6 Months' = '6month'
            '1 Year' = '12month'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
            'TimePeriod' {$apiParams.Add('period', $period[$TimePeriod])}
        }
    }
    process {
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
        }

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
                'PSTypeName' = 'PowerLFM.User.Artist'
                'Artist' = $artist.Name
                'PlayCount' = [int] $artist.PlayCount
                'Url' = [uri] $artist.Url
                'Id' = $artist.Mbid
            }

            Write-Output $artistInfo
        }
    }
}
