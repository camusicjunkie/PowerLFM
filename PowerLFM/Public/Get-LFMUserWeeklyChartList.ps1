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
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl
            if ($irm.Error) {Write-Output $irm; return}

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
