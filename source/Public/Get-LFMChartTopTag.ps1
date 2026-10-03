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

    process {
        $irm = Invoke-LFMApiMethod -Method 'chart.getTopTags' -Parameter $PSBoundParameters

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
}
