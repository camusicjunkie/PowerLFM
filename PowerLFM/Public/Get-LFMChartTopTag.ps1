function Get-LFMChartTopTag {
    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopTags')]
    param (
        [Parameter()]
        [ValidateRange(1,119)]
        [string] $Limit,

        [string] $Page
    )

    #Default hashtable
    $apiParams = [ordered] @{
        'method' = 'chart.getTopTags'
        'api_key' = $LFMConfig.APIKey
        'format' = 'json'
    }

    #Adding key/value to hashtable based off optional parameters
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
    $hash = $irm | ConvertTo-Hashtable
    
    foreach ($tag in $hash.Tags.Tag) {
        $tagInfo = [pscustomobject] @{
            'Tag' = ConvertTo-TitleCase -String $tag.Name
            'Url' = $tag.Url
            'Reach' = $tag.Reach
            'TotalTags' = $tag.Taggings
        }

        $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Chart.TopTags')
        Write-Output $tagInfo
    }
}
