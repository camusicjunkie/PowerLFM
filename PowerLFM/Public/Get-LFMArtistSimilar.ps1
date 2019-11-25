function Get-LFMArtistSimilar {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Similar')]
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

        [int] $Limit,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getSimilar'
            'api_key' = $script:LFMConfig.APIKey
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

            foreach ($similar in $irm.SimilarArtists.Artist) {
                $similarInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Artist.Similar'
                    'Artist' = $similar.Name
                    'Id' = $similar.Mbid
                    'Url' = [uri] $similar.Url
                    'Match' = [math]::Round($similar.Match, 2)
                }

                Write-Output $similarInfo
            }
        }
        catch {
            throw $_
        }
    }
}
