function Add-LFMConfiguration {
    # .ExternalHelp PowerLFM-help.xml

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
        [string] $SharedSecret
    )

    process {
        try {
            if ($PSCmdlet.ShouldProcess('Password Vault', 'Adding configuration')) {
                $keys = $PSBoundParameters.Keys.Where({$_ -in  @('ApiKey', 'SessionKey', 'SharedSecret')})

                foreach ($param in $keys) {
                    Add-LFMVaultCredential -UserName $param -Pass $PSBoundParameters[$param]
                }
            }
        }
        catch {
            throw $_
        }
    }
}
