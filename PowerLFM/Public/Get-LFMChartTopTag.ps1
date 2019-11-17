function Get-LFMChartTopTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Chart.TopTags')]
    param (
        [Parameter()]
        [ValidateRange(1, 119)]
        [int] $Limit,

        [int] $Page
    )

    $apiParams = @{
        'method' = 'chart.getTopTags'
        'api_key' = $LFMConfig.APIKey
        'format' = 'json'
    }

    $noCommonParams = Remove-CommonParameter $PSBoundParameters
    $convertedParams = ConvertTo-LFMParameter $noCommonParams

    $query = New-LFMApiQuery ($convertedParams + $apiParams)
    $apiUrl = "$baseUrl/?$query"

    try {
        $irm = Invoke-LFMApiUri -Uri $apiUrl

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
    catch {
        throw $_
    }
}
