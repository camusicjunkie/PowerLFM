function Set-LFMTrackLove {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    [OutputType('PowerLFM.Track.Love')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Track
    )

    begin {
        $apiSig = New-LFMTrackSignature -Method track.love -Artist $Artist -Track $Track

        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'track.love'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
        }
    }
    process {
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
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Adding love")) {
            $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
            Write-Verbose "$($iwr.StatusCode) $($iwr.StatusDescription)"
        }
    }
}
