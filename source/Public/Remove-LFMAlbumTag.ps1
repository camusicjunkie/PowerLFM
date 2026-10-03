function Remove-LFMAlbumTag {
    # .ExternalHelp PowerLFM-help.xml

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
        [ValidateNotNullOrEmpty()]
        [string] $Tag
    )

    process {
        if ($PSCmdlet.ShouldProcess("Album: $Album", "Removing album tag: $Tag")) {
            $null = Invoke-LFMApiMethod -Method 'album.removeTag' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.tagRemoved -f $Tag)
        }
    }
}
