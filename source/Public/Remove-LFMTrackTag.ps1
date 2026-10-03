function Remove-LFMTrackTag {
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
        [ValidateNotNullOrEmpty()]
        [string] $Tag
    )

    process {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Removing track tag: $Tag")) {
            $null = Invoke-LFMApiMethod -Method 'track.removeTag' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.tagRemoved -f $Tag)
        }
    }
}
