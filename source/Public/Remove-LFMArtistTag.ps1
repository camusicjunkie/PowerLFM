function Remove-LFMArtistTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param (
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
        if ($PSCmdlet.ShouldProcess("Artist: $Artist", "Removing artist tag: $Tag")) {
            $null = Invoke-LFMApiMethod -Method 'artist.removeTag' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.tagRemoved -f $Tag)
        }
    }
}
