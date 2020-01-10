function Remove-LFMVaultCredential {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    try {
        $vault = Get-PasswordVaultClass
        $vaultType = $vault.GetType().Name
        $credentials = Get-LFMVaultCredential

        foreach ($cred in $credentials) {
            if ($PSCmdlet.ShouldProcess("$module in $vaultType", "Removing credential for $($cred.UserName)")) {
                $vault.Remove($cred)
            }
        }
    } catch {
        Write-Error $_.Exception.Message
    }
}
