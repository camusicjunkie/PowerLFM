function Set-LFMTrackScrobble {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    [OutputType('PowerLFM.Track.Scrobble')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [datetime] $Timestamp,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int] $TrackNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int] $Duration,

        [Parameter()]
        [switch] $PassThru
    )

    begin {
        $apiParams = @{
            'method' = 'track.scrobble'
            'api_key' = $script:LFMConfig.ApiKey
            'sk' = $script:LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $apiSig = Get-LFMSignature -Method $apiParams.Method @noCommonParams
        $apiParams.Add('api_sig', $apiSig)

        $convertedParams = ConvertTo-LFMParameter $noCommonParams
        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Setting track to now playing")) {
            try {
                $irm = Invoke-LFMApiUri -Uri $apiUrl -Method Post

                $code = Get-LFMIgnoredMessage -Code $irm.Scrobbles.Scrobble.IgnoredMessage.Code
                if ($code.Code -ne 0) {
                    if ($null -eq $code.Message) {
                        throw $localizedData.errorFiltered2
                    }
                    else {
                        throw ($localizedData.errorFiltered -f $code.Message)
                    }
                }

                if ($PassThru) {
                    [pscustomobject] @{
                        PSTypeName = 'PowerLFM.Track.Scrobble'
                        Artist = $irm.Scrobbles.Scrobble.Artist.'#text'
                        Album = $irm.Scrobbles.Scrobble.Album.'#text'
                        Track = $irm.Scrobbles.Scrobble.Track.'#text'
                    }
                }
            }
            catch {
                throw $_
            }
        }
    }
}
