function Get-LFMTrackTopTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.TopTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'track')]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 1,
                   ParameterSetName = 'track')]
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
            'method' = 'track.getTopTags'
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

            foreach ($tag in $irm.TopTags.Tag) {
                $tagInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Track.Tag'
                    'Tag' = $tag.Name
                    'Url' = [uri] $tag.Url
                    'Match' = [int] $tag.Count
                }

                Write-Output $tagInfo
            }
        }
        catch {
            throw $_
        }
    }
}
