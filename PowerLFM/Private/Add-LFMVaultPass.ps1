function Add-LFMVaultPass {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Pass,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName
    )

    begin {
        try {
            [Void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
            $vault = New-Object -TypeName Windows.Security.Credentials.PasswordVault -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
        }

        $module = (Get-Command -Name $MyInvocation.MyCommand.Name).ModuleName
    }

    process {
        $noParams = @{
            'TypeName' = Windows.Security.Credentials.PasswordCredential
            'ArgumentList' = $module, $UserName, $Pass
        }
        $pwCred = New-Object @noParams

        try {
            if ($vault.FindAllByUserName("$UserName").Count -ne 0) {
                $message = "There is already a value present for $UserName, do you wish to update the value?"
                if ($PSCmdlet.ShouldProcess($vault, $message)) {
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
}
