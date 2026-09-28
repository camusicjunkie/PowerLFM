function Send-LFMScrobbleBatch {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [psobject[]] $Scrobble
    )

    # track.scrobble takes up to 50 plays in one call through array notation, which
    # neither Get-LFMSignature nor ConvertTo-LFMParameter can express: both map one
    # PowerShell parameter to one API parameter.
    $batchParams = @{ }
    for ($index = 0; $index -lt $Scrobble.Count; $index++) {
        $batchParams["artist[$index]"] = $Scrobble[$index].Artist
        $batchParams["track[$index]"] = $Scrobble[$index].Track
        $batchParams["timestamp[$index]"] = $Scrobble[$index].Timestamp

        if ($Scrobble[$index].Album) { $batchParams["album[$index]"] = $Scrobble[$index].Album }
        if ($Scrobble[$index].TrackNumber) { $batchParams["trackNumber[$index]"] = $Scrobble[$index].TrackNumber }
        if ($Scrobble[$index].Duration) { $batchParams["duration[$index]"] = $Scrobble[$index].Duration }
        if ($Scrobble[$index].Id) { $batchParams["mbid[$index]"] = $Scrobble[$index].Id }
    }

    $signedParams = $batchParams + @{
        'method'  = 'track.scrobble'
        'api_key' = $script:LFMConfig.ApiKey
        'sk'      = $script:LFMConfig.SessionKey
    }

    $signature = New-LFMApiQuery -InputObject $signedParams -Signature
    $apiSig = Get-Md5Hash -String "$signature$($script:LFMConfig.SharedSecret)"

    $query = New-LFMApiQuery -InputObject ($signedParams + @{ 'format' = 'json'; 'api_sig' = $apiSig })
    $apiUrl = "$baseUrl/?$query"

    $irm = Invoke-LFMApiUri -Uri $apiUrl -Method Post

    Write-Output @($irm.Scrobbles.Scrobble)
}
