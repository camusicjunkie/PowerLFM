function Get-LFMVaultCredential {
    [CmdletBinding()]
    param (
        [string] $UserName
    )

    try {
        $vault = Get-PasswordVaultClass

        if (-not (Test-LFMVaultCredential -Resource $module)) {
            throw
        }

        if ($PSBoundParameters.ContainsKey('UserName')) { $vault.Retrieve($module, $UserName) }
        else { $vault.FindAllByResource($module) }
    }
    catch {
        $errorMessage = $localizedData.errorCredentials -f $module

        $PSCmdlet.ThrowTerminatingError(
            [ErrorRecord]::new(
                $errorMessage,
                'PowerLFM.ElementNotFound',
                'ObjectNotFound',
                $MyInvocation.MyCommand.Name
            )
        )
    }
}
