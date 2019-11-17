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
        throw $_
    }
}
