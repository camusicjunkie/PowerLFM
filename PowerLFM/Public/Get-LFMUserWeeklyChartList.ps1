function Get-LFMUserWeeklyChartList {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyChartList')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName
    )

    begin {
        $apiParams = @{
            'method' = 'user.getWeeklyChartList'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $apiParams.Add('user', $UserName)

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
                'PSTypeName' = 'PowerLFM.User.WeeklyChartList'
                'StartDate' = $chart.From | ConvertFrom-UnixTime -Local
                'EndDate' = $chart.To | ConvertFrom-UnixTime -Local
            }

            Write-Output $chartInfo
        }
    }
}
