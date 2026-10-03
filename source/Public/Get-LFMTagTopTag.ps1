function Get-LFMTagTopTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTags')]
    param ()

    process {
        $irm = Invoke-LFMApiMethod -Method 'tag.getTopTags' -Parameter $PSBoundParameters

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
}
