function Add-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
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
        [string] $SharedSecret
    )

    process {
        try {
            $keys = $PSBoundParameters.Keys.Where({$_ -in  @('ApiKey', 'SessionKey', 'SharedSecret')})

            foreach ($param in $keys) {
                $ssParams = @{
                    Name = "LFM$param"
                    Secret = $PSBoundParameters[$param]
                    Vault = 'Microsoft.PowerShell.SecretStore'
                    NoClobber = $true
                }

                try {
                    $null = Get-Secret -Name "LFM$param" -ErrorAction Stop

                    $message = $localizedData.vaultCredPresent -f $param

                    if ($PSCmdlet.ShouldProcess('SecretStore', $message)) {
                        $ssParams.Remove('NoClobber')
                        Set-Secret @ssParams
                    }
                }
                catch {
                    Set-Secret @ssParams
                }
            }
        }
        catch {
            throw $_
        }
    }
}
