function Get-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    param ()

    try {
        $script:LFMConfig = [pscustomobject] @{
            'ApiKey' = Get-Secret -Name LFMApiKey -Vault BuiltInLocalVault -AsPlainText
            'SessionKey' = Get-Secret -Name LFMSessionKey -Vault BuiltInLocalVault -AsPlainText
            'SharedSecret' = Get-Secret -Name LFMSharedSecret -Vault BuiltInLocalVault -AsPlainText
        }
        Write-Verbose $localizedData.configInSession
    }
    catch {
        throw $_
    }
}
