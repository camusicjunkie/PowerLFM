function New-LFMApiQuery {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]

    param (
        [psobject] $InputObject
    )

    if ((Get-PSCallStack)[1].Command -like '*Signature') {
        $keyValues = $InputObject.GetEnumerator() | Sort-Object Key | ForEach-Object {
            "$($_.Key)$($_.Value)"
        }

        $query = $keyValues -join ''
    }
    else {
        $keyValues = $InputObject.GetEnumerator() | ForEach-Object {
            "$($_.Key)=$($_.Value)"
        }

        $query = $keyValues -join '&'
    }

    Write-Output $query
}
