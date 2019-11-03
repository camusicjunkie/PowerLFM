function Remove-LFMTrackTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag
    )

    process {
        $apiSigProps = @{
            'Track' = $Track
            'Artist' = $Artist
            'Tag' = $Tag
            'Method' = 'track.removeTag'
        }
        $apiSig = Get-LFMTrackSignature @apiSigProps

        $apiParams = @{
            'method' = 'track.removeTag'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
        }

        $apiParams.Add('track', $Track)
        $apiParams.Add('artist', $Artist)
        $apiParams.Add('tag', $Tag)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Removing track tag: $Tag")) {
            try {
                $irm = Invoke-LFMApiUri -Uri $apiUrl -Method Post
                if ($irm.Lfm.Status -eq 'ok') {Write-Verbose "Tag: $Tag has been removed"}
            }
            catch {
                throw $_
            }
        }
    }
}
