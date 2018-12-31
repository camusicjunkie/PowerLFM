function Get-LFMChartTopTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopTags')]
    param (
        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    $apiParams = @{
        'method' = 'chart.getTopTags'
        'api_key' = $LFMConfig.APIKey
        'format' = 'json'
    }

    switch ($PSBoundParameters.Keys) {
        'Limit' {$apiParams.add('limit', $Limit)}
        'Page' {$apiParams.add('page', $Page)}
    }

    #Building string to append to base url
    $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
        "$($_.Name)=$($_.Value)"
    }
    $string = $keyValues -join '&'

    $apiUrl = "$baseUrl/?$string"

    $irm = Invoke-RestMethod -Uri $apiUrl

    foreach ($tag in $irm.Tags.Tag) {
        $tagInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Chart.TopTags'
            'Tag' = ConvertTo-TitleCase -String $tag.Name
            'Url' = $tag.Url
            'Reach' = $tag.Reach
            'TotalTags' = $tag.Taggings
        }

        Write-Output $tagInfo
    }
}
