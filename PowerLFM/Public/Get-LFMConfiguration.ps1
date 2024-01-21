function Get-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    param ()

    try {
        $script:LFMConfig = [pscustomobject] @{
            'ApiKey' = Get-Secret -Name LFMApiKey -Vault Microsoft.PowerShell.SecretStore -AsPlainText
            'SessionKey' = Get-Secret -Name LFMSessionKey -Vault Microsoft.PowerShell.SecretStore -AsPlainText
            'SharedSecret' = Get-Secret -Name LFMSharedSecret -Vault Microsoft.PowerShell.SecretStore -AsPlainText
        }
        Write-Verbose $localizedData.configInSession
    }
    catch {
        throw $_
    }
}
