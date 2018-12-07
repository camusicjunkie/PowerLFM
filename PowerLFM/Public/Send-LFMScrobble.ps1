function Send-LFMScrobble {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    [OutputType('PowerLFM.Track.Scrobble')]
    param (
        [Parameter(Mandatory,
                    ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(Mandatory,
                    ValueFromPipelineByPropertyName)]
        [string] $Track,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Album
    )

    begin {
        $TimeStamp = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime() -uformat "%s"))

        if($null -ne $Album){
            $apiSig = New-LFMTrackSignature -Method track.scrobble -Artist $Artist -Track $Track -Album $Album -TimeStamp $TimeStamp
        }else{
            $apiSig = New-LFMTrackSignature -Method track.scrobble -Artist $Artist -Track $Track -TimeStamp $TimeStamp
        }
        
        
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'track.scrobble'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
            'format' = 'json'
        }
    }
    process {
        $apiParams.add('artist', $Artist)
        $apiParams.add('track', $Track)
        $apiParams.add('timestamp', $TimeStamp)
        if($null -ne $Album){
            $apiParams.add('album', $Album)
        }
        
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Artist: $Artist, Track: $Track", "Scrobbled")) {
            $Response = Invoke-RestMethod -Uri $apiUrl -Method Post
        
            if ($Response.scrobbles.'@attr'.accepted -ge 1) {
                Write-Output "$Track by $Artist successfully scobbled!"
            }
            else {
                Write-Warning "Your scrobble got lost. Try again later."
            }
        }
    }
}
