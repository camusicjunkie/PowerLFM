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
        $apiParams = [ordered] @{
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
        $irm = Invoke-RestMethod -Uri $apiUrl

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
