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

    process {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Adding track tag: $Tag")) {
            $null = Invoke-LFMApiMethod -Method 'track.addTags' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.tagAdded -f $Tag)
        }
    }
}
