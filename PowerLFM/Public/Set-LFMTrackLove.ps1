function Set-LFMTrackLove {
    [CmdletBinding()]
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
            'format' = 'json'
        }
    }
    process {
        #Adding key/value to hashtable. Added in the process block
        #to allow for pipeline input
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
        $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
        if ($iwr.StatusCode -eq 200) {
            Write-Output "You loved $Track by $Artist!"
        }
        else {
            Write-Warning "Your love got lost. Try again later."
        }
    }
}