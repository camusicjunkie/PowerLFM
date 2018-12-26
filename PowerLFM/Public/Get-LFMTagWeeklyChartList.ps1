function Get-LFMTagWeeklyChartList {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.WeeklyChartList')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Tag
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'tag.getWeeklyChartList'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
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
        $irm = Invoke-RestMethod -Uri $apiUrl

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
