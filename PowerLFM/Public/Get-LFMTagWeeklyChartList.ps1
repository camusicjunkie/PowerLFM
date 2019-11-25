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

    begin {
        $apiParams = @{
            'method' = 'tag.getWeeklyChartList'
            'api_key' = $script:LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $convertedParams = ConvertTo-LFMParameter $noCommonParams

        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

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
        catch {
            throw $_
        }
    }
}
