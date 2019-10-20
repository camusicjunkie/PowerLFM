function Set-LFMTrackNowPlaying {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int] $Duration
    )

    process {
        $apiSigParams = @{
            'Artist' = $Artist
            'Track' = $Track
            'Method' = 'track.updateNowPlaying'
        }

        $apiParams = @{
            'method' = 'track.updateNowPlaying'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
        }

        switch ($PSBoundParameters.Keys) {
            'Album' {
                $apiSigParams.Add('Album', $Album),
                $apiParams.Add('album', $Album)
            }
            'Id' {
                $apiSigParams.Add('Id', $Id)
                $apiParams.Add('mbid', $Id)
            }
            'Duration' {
                $apiSigParams.Add('Duration', $Duration)
                $apiParams.Add('duration', $Duration)
            }
        }

        $apiSig = Get-LFMTrackSignature @apiSigParams

        $apiParams.Add('api_sig', $apiSig)
        $apiParams.Add('artist', $Artist)
        $apiParams.Add('track', $Track)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Setting track to now playing")) {
            #$iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
            Write-Verbose "$($iwr.StatusCode) $($iwr.StatusDescription)"
        }
    }
}
