function Add-LFMTrackTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
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
        [ValidateCount(1, 10)]
        [string[]] $Tag
    )

    begin {
        $apiParams = @{
            'method' = 'track.addTags'
            'api_key' = $script:LFMConfig.ApiKey
            'sk' = $script:LFMConfig.SessionKey
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $apiSig = Get-LFMSignature -Method $apiParams.Method @noCommonParams
        $apiParams.Add('api_sig', $apiSig)

        $convertedParams = ConvertTo-LFMParameter $noCommonParams
        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
    }
    end {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Adding track tag: $Tag")) {
            try {
                $irm = Invoke-LFMApiUri -Uri $apiUrl -Method Post
                if ($irm.Lfm.Status -eq 'ok') {Write-Verbose "Tag: $Tag has been added"}
            }
            catch {
                throw $_
            }
        }
    }
}
