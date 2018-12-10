function Remove-LFMArtistTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Tag
    )

    begin {
        $apiSig = New-LFMArtistSignature -Method artist.removeTag -Artist $Artist -Tag $Tag

        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.removeTag'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
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
        if ($PSCmdlet.ShouldProcess("Artist: $Artist", "Removing artist tag")) {
            $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
            Write-Verbose "$($iwr.StatusCode) $($iwr.StatusDescription)"
        }
    }
}
