function Get-LFMTrackCorrection {
    # .ExternalHelp PowerLFM.psm1-help.xml

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
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $apiParams.add('track', $Track)
        $apiParams.add('artist', $Artist)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

        $correction = $irm.Corrections.Correction.Track
        $correctedTrackInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Track.Correction'
            'Track' = $correction.Name
            'TrackUrl' = $correction.Url
            'Artist' = $correction.Artist.Name
            'ArtistUrl' = $correction.Artist.Url
            'ArtistId' = $correction.Artist.Mbid
        }

        Write-Output $correctedTrackInfo
    }
}
