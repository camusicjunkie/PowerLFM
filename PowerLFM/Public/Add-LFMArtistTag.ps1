function Add-LFMArtistTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

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

    process {
        $apiSigParams = @{
            'Artist' = $Artist
            'Tag' = $Tag
            'Method' = 'artist.addTags'
        }
        $apiSig = Get-LFMArtistSignature @apiSigParams

        $apiParams = @{
            'method' = 'artist.addTags'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
        }

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
        if ($PSCmdlet.ShouldProcess("Artist: $Artist", "Adding artist tag: $Tag")) {
            $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
            Write-Verbose "$($iwr.StatusCode) $($iwr.StatusDescription)"
        }
    }
}
