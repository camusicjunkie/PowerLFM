function Get-LFMArtistTopTrack {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Track')]
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

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getTopTracks'
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

            foreach ($track in $irm.TopTracks.Track) {
                $trackInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Artist.Track'
                    'Track' = $track.Name
                    'Id' = $track.Mbid
                    'Url' = [uri] $track.Url
                    'Listeners' = [int] $track.Listeners
                    'PlayCount' = [int] $track.PlayCount
                }

                Write-Output $trackInfo
            }
        }
        catch {
            throw $_
        }
    }
}
