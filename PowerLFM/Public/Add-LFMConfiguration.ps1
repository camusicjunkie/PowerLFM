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
        [string] $SharedSecret
    )

    process {
        if ($PSCmdlet.ShouldProcess('Add key to vault', 'Adding configuration')) {

            $i = 1
            foreach ($param in $PSBoundParameters.Keys) {
                do {
                    Add-LFMVaultPass -UserName $param -Pass $PSBoundParameters[$param]
                    $i++
                }
                until ($i = 3)
            }
        }
    }
}
