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
            $script:LFMConfig = [pscustomobject] @{
                'APIKey' = $ak
                'String' = "api_key=$ak&sk=$sk"	
            }
            Write-Output $LFMConfig
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}