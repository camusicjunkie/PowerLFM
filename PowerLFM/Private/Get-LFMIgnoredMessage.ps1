function Get-LFMIgnoredMessage {
    param (
        [int] $Code
    )

    $ignoredCode = @{
        0 = $localizedData.codeNone
        1 = $localizedData.FilteredArtist
        2 = $localizedData.FilteredTrack
        3 = $localizedData.codeTimestampTooFarPast
        4 = $localizedData.codeTimestampTooFarFuture
        5 = $localizedData.codeScrobblesExceeded
    }

    [pscustomobject] @{
        Code = $Code
        Message = $ignoredCode[$Code]
    }
}
