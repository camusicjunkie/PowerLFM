function Get-PasswordVaultClass {
    param ()

    try {
        [Void] [Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
        New-Object -TypeName Windows.Security.Credentials.PasswordVault -ErrorAction Stop
    }
    catch {
        throw $script:localizedData.errorPasswordVaultClass
    }
}
