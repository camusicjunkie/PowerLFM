function Get-LFMIgnoredMessage {
    param (
        [int] $Code
    )

    $ignoredCode = @{
        0 = 'None (the request passed all filters)'
        1 = 'Filtered artist'
        2 = 'Filtered track'
        3 = 'Timestamp too far in the past'
        4 = 'Timestamp too far in the future'
        5 = 'Max daily scrobbles exceeded'
    }

    [pscustomobject] @{
        Code = $Code
        Message = $ignoredCode[$Code]
    }
}
