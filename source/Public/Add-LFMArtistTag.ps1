function Add-LFMArtistTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateCount(1, 10)]
        [string[]] $Tag
    )

    process {
        if ($PSCmdlet.ShouldProcess("Artist: $Artist", "Adding artist tag: $Tag")) {
            $null = Invoke-LFMApiMethod -Method 'artist.addTags' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.tagAdded -f $Tag)
        }
    }
}
