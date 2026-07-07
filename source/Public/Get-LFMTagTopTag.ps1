function Get-LFMTagTopTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTags')]
    param ()

    begin {
        $apiParams = @{
            'method' = 'tag.getTopTags'
            'api_key' = $script:LFMConfig.ApiKey
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
        $irm = Invoke-LFMApiUri -Uri $apiUrl

        foreach ($tag in $irm.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopTags'
                'Tag' = $tag.Name
                'Count' = [int] $tag.Count
                'Reach' = [int] $tag.Reach
            }

            $tagInfo
        }
    }
}
