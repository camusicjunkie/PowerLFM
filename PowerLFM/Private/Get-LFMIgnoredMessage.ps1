function Get-LFMIgnoredMessage {
    param (
        [int] $Code
    )

    $ignoredCode = @{
        0 = $script:localizedData.codeNone
        1 = $script:localizedData.FilteredArtist
        2 = $script:localizedData.FilteredTrack
        3 = $script:localizedData.codeTimestampTooFarPast
        4 = $script:localizedData.codeTimestampTooFarFuture
        5 = $script:localizedData.codeScrobblesExceeded
    }

    [pscustomobject] @{
        Code = $Code
        Message = $ignoredCode[$Code]
    }
}
