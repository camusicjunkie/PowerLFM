function Get-LFMTagTopTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTags')]
    param ()

    begin {
        $apiParams = @{
            'method' = 'tag.getTopTags'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl

        foreach ($tag in $irm.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopTags'
                'Tag' = $tag.Name
                'Count' = $tag.Count
                'Reach' = $tag.Reach
            }

            Write-Output $tagInfo
        }
    }
}
