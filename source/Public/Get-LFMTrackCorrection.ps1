function Get-LFMTrackCorrection {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.Correction')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist
    )

    begin {
        $apiParams = @{
            'method' = 'track.getCorrection'
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
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            $correction = $irm.Corrections.Correction.Track
            $correctedTrackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Track.Correction'
                'Track' = $correction.Name
                'TrackUrl' = [uri] $correction.Url
                'Artist' = $correction.Artist.Name
                'ArtistUrl' = [uri] $correction.Artist.Url
                'ArtistId' = $correction.Artist.Mbid
            }

            Write-Output $correctedTrackInfo
        }
        catch {
            throw $_
        }
    }
}
