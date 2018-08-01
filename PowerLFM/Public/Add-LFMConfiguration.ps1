function Add-LFMConfig {
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

            foreach ($param in $PSBoundParameters) {
                Add-LFMVaultPass -UserName $param.Key -Pass $param.Value -Confirm
            }
        }
    }
}
