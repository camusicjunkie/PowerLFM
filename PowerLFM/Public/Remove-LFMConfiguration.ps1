function Remove-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    $module = (Get-Command -Name $MyInvocation.MyCommand.Name).ModuleName

    try {
        [Void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
        $vault = New-Object -TypeName Windows.Security.Credentials.PasswordVault -ErrorAction Stop

        $credentials = $vault.RetrieveAll() | Where-Object Resource -eq $module

        foreach ($cred in $credentials) {
            if ($PSCmdlet.ShouldProcess("$module in $($vault.GetType().Name)", "Removing credential for $($cred.UserName)")) {
                $vault.Remove($cred)
            }
        }
    } catch {
        Write-Error $_.Exception.Message
    }
}
