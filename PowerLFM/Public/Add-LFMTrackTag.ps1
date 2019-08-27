function Add-LFMTrackTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

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

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateCount(1,10)]
        [string[]] $Tag
    )

    process {
        $apiSigParams = @{
            'Track' = $Track
            'Artist' = $Artist
            'Tag' = $Tag
            'Method' = 'track.addTags'
        }
        $apiSig = Get-LFMTrackSignature @apiSigParams

        $apiParams = @{
            'method' = 'track.addTags'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
        }

        $apiParams.Add('track', $Track)
        $apiParams.Add('artist', $Artist)
        $apiParams.Add('tags', $Tag)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Adding track tag: $Tag")) {
            $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
            Write-Verbose "$($iwr.StatusCode) $($iwr.StatusDescription)"
        }
    }
}
