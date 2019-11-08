function Get-LFMTrackSimilar {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.Similar')]
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

        [int] $Limit = '5',

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'track.getSimilar'
            'api_key' = $LFMConfig.APIKey
            'limit' = $Limit
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

            foreach ($similar in $irm.SimilarTracks.Track) {
                $similarInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Track.Similar'
                    'Track' = $similar.Name
                    'Artist' = $similar.Artist.Name
                    'Id' = $similar.Mbid
                    'PlayCount' = [int] $similar.PlayCount
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
