function Remove-CommonParameter {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]

    param (
        [psobject] $InputObject
    )

    $commonParams = [System.Management.Automation.PSCmdlet]::CommonParameters +
                    [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    $keysToRemove = $InputObject.Keys.Where({ $_ -in $commonParams })
    $null = $keysToRemove | ForEach-Object { $InputObject.Remove($_) }

    Write-Output $InputObject
}
