function Set-LFMTrackUnlove {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    [OutputType('PowerLFM.Track.Unlove')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track
    )

    process {
        $apiSigParams = @{
            'Artist' = $Artist
            'Track' = $Track
            'Method' = 'track.unlove'
        }
        $apiSig = Get-LFMTrackSignature @apiSigParams

        $apiParams = @{
            'method' = 'track.unlove'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
        }

        $apiParams.add('artist', $Artist)
        $apiParams.add('track', $Track)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Removing love")) {
            $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
            Write-Verbose "$($iwr.StatusCode) $($iwr.StatusDescription)"
        }
    }
}
