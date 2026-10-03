function Set-LFMTrackLove {
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
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Adding love")) {
            $null = Invoke-LFMApiMethod -Method 'track.love' -Parameter $PSBoundParameters
            Write-Verbose ($localizedData.trackLoved -f $Track)
        }
    }
}
