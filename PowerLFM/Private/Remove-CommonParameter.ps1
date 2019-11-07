function Remove-CommonParameter {
    param (
        [Parameter()]
        [psobject] $InputObject
    )

    $commonParams = [System.Management.Automation.PSCmdlet]::CommonParameters +
                    [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    #$hash = @{}

    #$filtered = $InputObject.GetEnumerator().Where({$_.Name -notin $commonParams})
    $keysToRemove = $InputObject.Keys.Where({$_ -in $commonParams})
    $keysToRemove | ForEach-Object {$InputObject.Remove($_)}
    #foreach ($parameter in $filtered) {
    #    $hash.Add($parameter.Key, $parameter.Value)
    #}

    Write-Output ([hashtable] $InputObject)
}
