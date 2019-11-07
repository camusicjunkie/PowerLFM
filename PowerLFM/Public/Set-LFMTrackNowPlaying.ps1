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

    begin {
        $apiParams = @{
            'method' = 'track.updateNowPlaying'
            'api_key' = $LFMConfig.ApiKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $convertedParams = ConvertTo-LFMParameter $noCommonParams

        $apiSig = Get-LFMTrackSignature -Method $apiParams.Method @convertedParams
        $apiParams.Add('api_sig', $apiSig)

        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
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
