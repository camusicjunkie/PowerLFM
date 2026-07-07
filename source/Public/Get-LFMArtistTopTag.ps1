function Get-LFMArtistTopTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Tag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'artist')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getTopTags'
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
                'PSTypeName' = 'PowerLFM.Artist.Tag'
                'Tag' = $tag.Name
                'Url' = [uri] $tag.Url
                'Match' = [int] $tag.Count
            }

            $tagInfo
        }
    }
}
