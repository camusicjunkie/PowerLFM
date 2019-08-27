function Get-LFMTagWeeklyChartList {
    # .ExternalHelp PowerLFM.psm1-help.xml

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
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $apiParams.Add('tag', $Tag)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
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
