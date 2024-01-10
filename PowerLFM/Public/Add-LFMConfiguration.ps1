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
                    Vault = 'BuiltInLocalVault'
                    NoClobber = $true
                }

                try {
                    $null = Get-Secret -Name "LFM$param" -ErrorAction Stop

                    $message = "There is already a value present for $param, do you wish to update the value?"

                    if ($PSCmdlet.ShouldProcess('BuiltInLocalVault', $message)) {
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
