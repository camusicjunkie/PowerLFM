function Get-LFMPasswordCredential {
    param (
        $UserName,
        $Pass
    )

    try {
        $noParams = @{
            'TypeName' = [Windows.Security.Credentials.PasswordCredential]
            'ArgumentList' = $module, $UserName, $Pass
            'ErrorAction' = 'Stop'
        }

        New-Object @noParams
    }
    catch {
        throw $localizedData.errorPasswordCredentialObject
    }
}
