function Get-LFMTagSimilar {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.Similar')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'tag.getSimilar' -Parameter $PSBoundParameters

        $tagInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Tag.Similar'
            'Tag' = $irm.Tag.Name
            'Url' = [uri] $irm.Tag.Url
        }

        # This api method seems broken at the moment.
        # It does not return anything.
        Write-Output $tagInfo
    }
}
