function Remove-CommonParameter {
    param (
        [Parameter()]
        [psobject] $InputObject
    )

    $commonParams = [System.Management.Automation.PSCmdlet]::CommonParameters +
                    [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    $hash = @{}

    $filtered = $InputObject.GetEnumerator().Where({$_.Name -notin $commonParams})
    foreach ($parameter in $filtered) {
        $hash.Add($parameter.Key, $parameter.Value)
    }

    Write-Output $hash
}
