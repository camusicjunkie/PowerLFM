function Get-LFMTagTopTag {
    # .ExternalHelp PowerLFM-help.xml

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
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl
            if ($irm.Error) {Write-Output $irm; return}

            foreach ($tag in $irm.TopTags.Tag) {
                $tagInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Tag.TopTags'
                    'Tag' = $tag.Name
                    'Count' = [int] $tag.Count
                    'Reach' = [int] $tag.Reach
                }

                Write-Output $tagInfo
            }
        }
        catch {
            throw $_
        }
    }
}
