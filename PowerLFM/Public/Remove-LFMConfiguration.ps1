function Remove-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    process {
        try {
            $secrets = Get-SecretInfo -Name LFM* -Vault BuiltInLocalVault

            foreach ($secret in $secrets) {
                if ($PSCmdlet.ShouldProcess('BuiltInLocalVault', "Removing secret: $($secret.Name)")) {
                    Remove-Secret -Name $secret.Name -Vault BuiltInLocalVault -Verbose
                }
            }
        } catch {
            throw $_
        }
    }
}
