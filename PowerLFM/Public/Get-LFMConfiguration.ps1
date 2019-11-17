function Get-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    param ()

    $module = 'PowerLFM'

    try {
        $script:LFMConfig = [pscustomobject] @{
            'APIKey' = (Get-VaultPassword -Resource $module -Name 'ApiKey')
            'SessionKey' = (Get-VaultPassword -Resource $module -Name 'SessionKey')
            'SharedSecret' = (Get-VaultPassword -Resource $module -Name 'SharedSecret')
        }
        Write-Verbose 'LFMConfig is loaded in to the session'
    }
    catch {
        Write-Error "Could not retrieve credentials for $module in Password Vault. Run Add-LFMConfiguration with proper keys."
    }
}
