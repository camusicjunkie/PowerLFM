function Get-LFMTagInfo {
    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [Parameter()]
        [string] $Language
    )

    begin {
        #Default hashtable
        $apiParams = @{
            'method' = 'tag.getInfo'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Language' {$apiParams.add('lang', $Language)}
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

        $tagInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Tag.Info'
            'Tag' = $irm.Tag.Name
            'Url' = [uri] "http://www.last.fm/tag/$Tag".Replace(' ', '+')
            'Reach' = [int] $irm.Tag.Reach
            'TotalTags' = [int] $irm.Tag.Total
            'Summary' = $irm.Tag.Wiki.Summary
        }

        Write-Output $tagInfo
    }
}
