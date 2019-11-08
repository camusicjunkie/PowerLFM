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
        $apiParams = @{
            'method' = 'tag.getSimilar'
            'api_key' = $LFMConfig.APIKey
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
