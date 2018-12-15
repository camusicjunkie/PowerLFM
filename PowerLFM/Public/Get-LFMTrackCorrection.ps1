function Get-LFMTrackCorrection {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.Correction')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'track.getCorrection'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'Track' {$apiParams.add('track', $Track)}
            'Artist' {$apiParams.add('artist', $Artist)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable

        $correction = $hash.Corrections.Correction.Track
        $correctedTrackInfo = [pscustomobject] @{
            'Track' = $correction.Name
            'TrackUrl' = $correction.Url
            'Artist' = $correction.Artist.Name
            'ArtistUrl' = $correction.Artist.Url
            'ArtistId' = $correction.Artist.Mbid
        }

        $correctedTrackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Track.Correction')
        Write-Output $correctedTrackInfo
    }
}
