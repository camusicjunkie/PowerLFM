function Get-LFMUserWeeklyChartList {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyChartList')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getWeeklyChartList'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable
         
        foreach ($chart in ($hash.WeeklyChartList.Chart)) {
            $chartInfo = [pscustomobject] @{
                'UserName' = $hash.WeeklyChartList.'@attr'.User
                'From' = $chart.From
                'To' = $chart.To
            }

            $chartInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.WeeklyChartList')
            Write-Output $chartInfo
        }
    }
}
