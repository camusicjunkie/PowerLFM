function Set-LFMTrackUnlove {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    [OutputType('PowerLFM.Track.Unlove')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Track
    )

    begin {
        $apiSig = New-LFMTrackSignature -Method track.unlove -Artist $Artist -Track $Track
        
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'track.unlove'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
            'format' = 'json'
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
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Removing love")) {
            Invoke-RestMethod -Uri $apiUrl -Method Post | Out-Null

            if ($iwr.StatusCode -eq 200) {
                Write-Output "You unloved $Track by $Artist!"
            }
            else {
                Write-Warning "We know you still love it. Try again later."
            }
        }
    }
}