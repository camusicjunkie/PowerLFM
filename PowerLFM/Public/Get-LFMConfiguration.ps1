function Get-LFMConfiguration {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$RegistryKeyPath = "HKCU:\Software\$projectName"
    )
	Write-Verbose $projectName
    $ErrorActionPreference = 'Stop'
    function decrypt([string]$TextToDecrypt) {
        $secure = ConvertTo-SecureString $TextToDecrypt
        $hook = New-Object system.Management.Automation.PSCredential("test", $secure)
        $plain = $hook.GetNetworkCredential().Password
        return $plain
    }

    try {
        if (-not (Test-Path -Path $RegistryKeyPath)) {
            Write-Verbose "No $projectName configuration found in registry"
        }
        else {
            $keyValues = Get-ItemProperty -Path $RegistryKeyPath
            $ak = decrypt $keyValues.APIKey
            $sk = decrypt $keyValues.SessionKey
            $ss = decrypt $keyValues.SharedSecret
            $script:LFMConfig = [pscustomobject] @{
                'APIKey' = $ak
                'SessionKey' = $sk
                'SharedSecret' = $ss
            }
            Write-Output $LFMConfig
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
