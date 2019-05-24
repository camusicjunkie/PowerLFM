function Get-LFMTagSimilar {
    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.Similar')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag
    )

    begin {
        #Default hashtable
        $apiParams = @{
            'method' = 'tag.getSimilar'
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
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
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
            'PSTypeName' = 'PowerLFM.Tag.Similar'
            'Tag' = $irm.Tag.Name
            'Url' = $irm.Tag.Url
        }

        # This api method seems broken at the moment.
        # It does not return anything.
        Write-Output $tagInfo
    }
}
