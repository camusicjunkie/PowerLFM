function Remove-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    process {
        try {
            $secrets = Get-SecretInfo -Name LFM* -Vault Microsoft.PowerShell.SecretStore

            foreach ($secret in $secrets) {
                if ($PSCmdlet.ShouldProcess('Microsoft.PowerShell.SecretStore', "Removing secret: $($secret.Name)")) {
                    Remove-Secret -Name $secret.Name -Vault Microsoft.PowerShell.SecretStore -Verbose
                }
            }
        } catch {
            throw $_
        }
    }
}
