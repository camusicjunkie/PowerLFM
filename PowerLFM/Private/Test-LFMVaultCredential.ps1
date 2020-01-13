function Test-LFMVaultCredential {
    param (
        [string] $Resource,
        [string] $UserName
    )

    try {
        $vault = Get-PasswordVaultClass

        if ($PSBoundParameters.ContainsKey('Resource')) { $vault.FindAllByResource($Resource) }
        elseif ($PSBoundParameters.ContainsKey('UserName')) { $vault.FindAllByUserName($UserName) }

        Write-Output $true
    }
    catch {
        if ((Get-PSCallStack)[2].Command -eq 'Remove-LFMVaultCredential') {
            exit
        }
        else {
            Write-Output $false
        }
    }
}
