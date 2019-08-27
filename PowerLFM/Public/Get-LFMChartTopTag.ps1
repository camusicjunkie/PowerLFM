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
        'Limit' {$apiParams.Add('limit', $Limit)}
        'Page' {$apiParams.Add('page', $Page)}
    }

    #Building string to append to base url
    $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
        "$($_.Name)=$($_.Value)"
    }
    $string = $keyValues -join '&'

    $apiUrl = "$baseUrl/?$string"

    try {
        $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        if ($irm.error) {
            [pscustomobject] @{
                'Error' = $irm.error
                'Message' = $irm.message
            }
            return
        }
    }
    catch {
        $response = $_.errorDetails.message | ConvertFrom-Json

        [pscustomobject] @{
            'Error' = $response.error
            'Message' = $response.message
        }
        return
    }

    foreach ($tag in $irm.Tags.Tag) {
        $tagInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Chart.TopTags'
            'Tag' = ConvertTo-TitleCase -String $tag.Name
            'Url' = [uri] $tag.Url
            'Reach' = [int] $tag.Reach
            'TotalTags' = [int] $tag.Taggings
        }

        Write-Output $tagInfo
    }
}
