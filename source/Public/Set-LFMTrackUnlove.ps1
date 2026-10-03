function Set-LFMTrackUnlove {
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
        [string] $Track
    )

    process {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Removing love")) {
            $null = Invoke-LFMApiMethod -Method 'track.unlove' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.trackUnloved -f $Track)
        }
    }
}
