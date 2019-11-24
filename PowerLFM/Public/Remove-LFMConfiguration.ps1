function Remove-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    param ()

    process {
        try {
            if ($PSCmdlet.ShouldProcess('Password Vault', 'Removing configuration')) {
                Remove-LFMVaultCredential
            }
        } catch {
            throw $_
        }
    }
}
