function Add-LFMConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,
	
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $SessionKey,
	
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $RegistryKeyPath = "HKCU:\Software\$ProjectName"
    )

    function encrypt([string]$TextToEncrypt) {
        $secure = ConvertTo-SecureString $TextToEncrypt -AsPlainText -Force
        $encrypted = $secure | ConvertFrom-SecureString
        return $encrypted
    }

    if (-not (Test-Path -Path $RegistryKeyPath)) {
        $niParams = @{
            'Path' = ($RegistryKeyPath | Split-Path -Parent)
            'Name' = ($RegistryKeyPath | Split-Path -Leaf)
        }
        New-Item @niParams | Out-Null
    }
	
    $values = 'APIKey', 'SessionKey'
    foreach ($val in $values) {
        if ((Get-Item -Path $RegistryKeyPath).GetValue($val)) {
            Write-Verbose "'$RegistryKeyPath\$val' already exists. Skipping."
        }
        else {
            Write-Verbose "Creating $RegistryKeyPath\$val"
            $nipParams = @{
                'Path'  = $RegistryKeyPath
                'Name'  = $val
                'Value' = $(encrypt $((Get-Variable $val).Value))
                'Force' = $true
            }
            New-ItemProperty @nipParams | Out-Null
        }
    }
}