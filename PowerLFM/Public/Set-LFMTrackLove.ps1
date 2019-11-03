function Set-LFMTrackLove {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
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
            'Method' = 'track.love'
        }
        $apiSig = Get-LFMTrackSignature @apiSigParams

        $apiParams = @{
            'method' = 'track.love'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
        }

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
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Adding love")) {
            try {
                $irm = Invoke-LFMApiUri -Uri $apiUrl -Method Post
                if ($irm.Lfm.Status -eq 'ok') {Write-Verbose "Track: $Track has been loved"}
            }
            catch {
                throw $_
            }
        }
    }
}
