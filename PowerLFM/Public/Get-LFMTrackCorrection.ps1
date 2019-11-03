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
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $apiParams.Add('track', $Track)
        $apiParams.Add('artist', $Artist)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
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
