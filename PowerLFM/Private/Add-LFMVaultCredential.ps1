function Add-LFMVaultCredential {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [string] $UserName,

        [Parameter(Mandatory)]
        [string] $Pass
    )

    $vaultType = $vault.GetType().Name

    $pwCred = Get-LFMPasswordCredential -UserName $UserName -Pass $Pass

    try {
        if (Test-LFMVaultCredential -UserName $UserName) {
            $message = $localizedData.vaultCredPresent -f $UserName

            if ($PSCmdlet.ShouldProcess($vaultType, $message)) {
                $vault.Add($pwCred)
            }
        }
        else {
            $vault.Add($pwCred)
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
