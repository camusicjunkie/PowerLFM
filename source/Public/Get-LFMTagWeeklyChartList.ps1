function Get-LFMTagWeeklyChartList {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.WeeklyChartList')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'tag.getWeeklyChartList' -Parameter $PSBoundParameters

        $chartList = $irm.WeeklyChartList.Chart.GetEnumerator() |
            Sort-Object {$_.From} -Descending

        foreach ($chart in $chartList) {
            $chartInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.WeeklyChartList'
                'StartDate' = $chart.From | ConvertFrom-UnixTime -Local
                'EndDate' = $chart.To | ConvertFrom-UnixTime -Local
            }

            Write-Output $chartInfo
        }
    }
}
