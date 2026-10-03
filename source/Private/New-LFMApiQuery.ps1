function New-LFMApiQuery {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]

    param (
        [psobject] $InputObject
    )

    $keyValues = $InputObject.GetEnumerator() | ForEach-Object {
        "$($_.Key)=$([Uri]::EscapeDataString($_.Value))"
    }

    $query = $keyValues -join '&'

    Write-Output $query
}
