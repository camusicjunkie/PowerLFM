function Remove-LFMVaultCredential {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    $vaultType = $vault.GetType().Name

    try {
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
