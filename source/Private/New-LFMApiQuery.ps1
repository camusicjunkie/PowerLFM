function New-LFMApiQuery {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]

    param (
        [psobject] $InputObject,
        [switch] $Signature
    )

    if ($Signature) {
        # Ordinal, not culture-aware: Last.fm sorts parameter names bytewise, and a
        # batched scrobble's names carry brackets, which a culture-aware sort weights
        # differently from the server would.
        $keys = [string[]] $InputObject.Keys
        [array]::Sort($keys, [StringComparer]::Ordinal)

        $keyValues = $keys | ForEach-Object {
            "$_$($InputObject[$_])"
        }

        $query = $keyValues -join ''
    }
    else {
        $keyValues = $InputObject.GetEnumerator() | ForEach-Object {
            "$($_.Key)=$([Uri]::EscapeDataString($_.Value))"
        }

        $query = $keyValues -join '&'
    }

    Write-Output $query
}
