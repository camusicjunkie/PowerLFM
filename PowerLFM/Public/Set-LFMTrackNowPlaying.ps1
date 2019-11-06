function Set-LFMTrackNowPlaying {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int] $Duration,

        [Parameter()]
        [switch] $PassThru
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
            'format' = 'json'
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
            try {
                $irm = Invoke-LFMApiUri -Uri $apiUrl -Method Post

                $code = Get-LFMIgnoredMessage -Code $irm.NowPlaying.IgnoredMessage.Code
                if ($code.Code -ne 0) {
                    throw "Request has been filtered because of bad meta data. $($code.Message)."
                }

                if ($PassThru) {
                    [pscustomobject] @{
                        Artist = $irm.NowPlaying.Artist.'#text'
                        Album = $irm.NowPlaying.Album.'#text'
                        Track = $irm.NowPlaying.Track.'#text'
                    }
                }
            }
            catch {
                throw $_
            }
        }
    }
}
