function Remove-LFMAlbumTag {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Tag
    )

    begin {
        $apiSigProps = @{
            'Album' = $Album
            'Artist' = $Artist
            'Tag' = $Tag
            'Method' = 'album.removeTag'
        }
        
        $apiSig = New-LFMAlbumSignature @apiSigProps
        
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'album.removeTag'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
            'format' = 'json'
        }
    }
    process {
        #Adding key/value to hashtable. Added in the process block
        #to allow for pipeline input
        $apiParams.add('album', $Album)
        $apiParams.add('artist', $Artist)
        $apiParams.add('tags', $Tag)
        
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Album: $Album", "Removing album tag")) {
            Invoke-RestMethod -Uri $apiUrl -Method Post | Out-Null
        }
    }
}