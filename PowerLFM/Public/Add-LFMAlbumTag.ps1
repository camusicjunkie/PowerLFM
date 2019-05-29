function Add-LFMAlbumTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
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
        [ValidateCount(1,10)]
        [string[]] $Tag
    )

    process {
        $apiSigParams = @{
            'Album' = $Album
            'Artist' = $Artist
            'Tag' = $Tag
            'Method' = 'album.addTags'
        }
        $apiSig = Get-LFMAlbumSignature @apiSigParams

        $apiParams = @{
            'method' = 'album.addTags'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
        }

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
        if ($PSCmdlet.ShouldProcess("Album: $Album", "Adding album tag: $Tag")) {
            $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post
            Write-Verbose "$($iwr.StatusCode) $($iwr.StatusDescription)"
        }
    }
}
