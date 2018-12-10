function Get-LFMConfiguration {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    param ()

    $module = (Get-Command -Name $MyInvocation.MyCommand.Name).ModuleName

    try {
        [Void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
        $vault = New-Object -TypeName Windows.Security.Credentials.PasswordVault -ErrorAction Stop

        $ak = $vault.Retrieve($module, 'APIKey').Password
        $sk = $vault.Retrieve($module, 'SessionKey').Password
        $ss = $vault.Retrieve($module, 'SharedSecret').Password
        $script:LFMConfig = [pscustomobject] @{
            'APIKey' = $ak
            'SessionKey' = $sk
            'SharedSecret' = $ss
        }
        Write-Verbose 'LFMConfig is loaded in to the session'
    } catch {
        Write-Error $_.Exception.Message
    }
}
