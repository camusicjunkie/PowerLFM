function Get-VaultPassword {
    [CmdletBinding()]
    param (
        [string] $Resource,
        [string] $Name
    )

    try {
        [Void] [Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
        $vault = New-Object -TypeName Windows.Security.Credentials.PasswordVault -ErrorAction Stop

        $vault.Retrieve($Resource, $Name).Password
    }
    catch {
        throw "Could not retrieve credentials for $Resource in Password Vault. Run Add-LFMConfiguration with proper keys."
    }
}
