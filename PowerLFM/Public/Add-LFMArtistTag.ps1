function Add-LFMArtistTag {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateCount(1,10)]
        [string[]] $Tag
    )

    begin {
        $apiSig = New-LFMArtistSignature -Method artist.addTags -Artist $Artist -Tag $Tag
        
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.addTags'
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
        $apiParams.add('tags', $Tag)
        
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Artist: $Artist", "Adding artist tag")) {
            Invoke-RestMethod -Uri $apiUrl -Method Post | Out-Null
        }
    }
}