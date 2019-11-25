function Get-LFMUserWeeklyChartList {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyChartList')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName
    )

    begin {
        $apiParams = @{
            'method' = 'user.getWeeklyChartList'
            'api_key' = $script:LFMConfig.APIKey
            'sk' = $script:LFMConfig.SessionKey
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

            $chartList = $irm.WeeklyChartList.Chart |
                Sort-Object -Property From -Descending

            foreach ($chart in $chartList) {
                $chartInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.WeeklyChartList'
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
