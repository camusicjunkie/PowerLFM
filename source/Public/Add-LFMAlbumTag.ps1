function Add-LFMAlbumTag {
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
        [ValidateCount(1, 10)]
        [string[]] $Tag
    )

    process {
        if ($PSCmdlet.ShouldProcess("Album: $Album", "Adding album tag: $Tag")) {
            $null = Invoke-LFMApiMethod -Method 'album.addTags' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.tagAdded -f $Tag)
        }
    }
}
