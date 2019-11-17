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

    begin {
        $apiParams = @{
            'method' = 'tag.getInfo'
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
                'PSTypeName' = 'PowerLFM.Tag.Info'
                'Tag' = $irm.Tag.Name
                'Url' = [uri] "http://www.last.fm/tag/$Tag" -replace ' ', '+'
                'Reach' = [int] $irm.Tag.Reach
                'TotalTags' = [int] $irm.Tag.Total
                'Summary' = $irm.Tag.Wiki.Summary
            }

            Write-Output $tagInfo
        }
        catch {
            throw $_
        }
    }
}
