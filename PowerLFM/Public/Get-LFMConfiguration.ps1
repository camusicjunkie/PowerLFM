function Get-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    param ()

    try {
        $script:LFMConfig = [pscustomobject] @{
            'APIKey' = (Get-LFMVaultCredential -UserName 'ApiKey').Password
            'SessionKey' = (Get-LFMVaultCredential -UserName 'SessionKey').Password
            'SharedSecret' = (Get-LFMVaultCredential -UserName 'SharedSecret').Password
        }
        Write-Verbose $localizedData.configInSession
    }
    catch {
        throw $_
    }
}
