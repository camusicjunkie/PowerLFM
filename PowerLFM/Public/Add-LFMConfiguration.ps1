function Add-LFMConfiguration {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,
	
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $SessionKey,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $SharedSecret,
	
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $RegistryKeyPath = "HKCU:\Software\$ProjectName"
    )

    function encrypt([string]$TextToEncrypt) {
        $secure = ConvertTo-SecureString $TextToEncrypt -AsPlainText -Force
        $encrypted = $secure | ConvertFrom-SecureString
        return $encrypted
    }

    if ($PSCmdlet.ShouldProcess("Registry key path: $RegistryKeyPath",
                                "Adding configuration")) {
        if (-not (Test-Path -Path $RegistryKeyPath)) {
            $niParams = @{
                'Path' = ($RegistryKeyPath | Split-Path -Parent)
                'Name' = ($RegistryKeyPath | Split-Path -Leaf)
            }
            New-Item @niParams | Out-Null
        }
        
        $values = 'APIKey', 'SessionKey', 'SharedSecret'
        foreach ($value in $values) {
            if ((Get-Item -Path $RegistryKeyPath).GetValue($value)) {
                Write-Verbose "'$RegistryKeyPath\$value' already exists. Skipping."
            }
            else {
                Write-Verbose "Creating $RegistryKeyPath\$value"
                $nipParams = @{
                    'Path'  = $RegistryKeyPath
                    'Name'  = $value
                    'Value' = $(encrypt $((Get-Variable $value).Value))
                    'Force' = $true
                }
                New-ItemProperty @nipParams | Out-Null
            }
        }
    }
}