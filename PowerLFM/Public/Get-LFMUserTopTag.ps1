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

    begin {
        $apiParams = @{
            'method' = 'user.getTopTags'
            'api_key' = $script:LFMConfig.APIKey
            'sk' = $script:LFMConfig.SessionKey
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
        catch {
            throw $_
        }
    }
}
