function Get-LFMUserTopTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopTag')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [int] $Limit
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'user.getTopTags' -Parameter $PSBoundParameters

        foreach ($tag in $irm.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.TopTag'
                'Tag' = $tag.Name
                'TagUrl' = [uri] $tag.Url
                'Count' = [int] $tag.Count
            }

            Write-Output $tagInfo
        }
    }
}
