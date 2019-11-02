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
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.Similar'
                'Tag' = $irm.Tag.Name
                'Url' = [uri] $irm.Tag.Url
            }

            # This api method seems broken at the moment.
            # It does not return anything.
            Write-Output $tagInfo
        }
        catch {
            throw $_
        }
    }
}
