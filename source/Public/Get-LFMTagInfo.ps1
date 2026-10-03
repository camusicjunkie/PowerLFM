function Get-LFMTagInfo {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [Parameter()]
        [string] $Language
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'tag.getInfo' -Parameter $PSBoundParameters

        $tagInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Tag.Info'
            'Tag' = $irm.Tag.Name
            'Url' = [uri] "http://www.last.fm/tag/$Tag" -replace ' ', '+'
            'Reach' = [int] $irm.Tag.Reach
            'TotalTags' = [int] $irm.Tag.Total
            'Summary' = $irm.Tag.Wiki.Summary
        }

        Write-Output $tagInfo
    }
}
