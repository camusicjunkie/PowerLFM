function ConvertTo-LFMParameter {
    param (
        [psobject] $InputObject
    )

    $lfmParameter = @{
        'Album'       = 'album'
        'Artist'      = 'artist'
        'AutoCorrect' = 'autocorrect'
        'City'        = 'location'
        'Country'     = 'country'
        'Duration'    = 'duration'
        'EndDate'     = 'to'
        'Id'          = 'mbid'
        'Language'    = 'lang'
        'Limit'       = 'limit'
        'Page'        = 'page'
        'StartDate'   = 'from'
        'Tag'         = 'tags'
        'TagType'     = 'taggingtype'
        'TimePeriod'  = 'period'
        'Timestamp'   = 'timestamp'
        'Track'       = 'track'
        'UserName'    = 'user'
        'Token'       = 'token'
        'ApiKey'      = 'api_key'
    }

    $period = @{
        'Overall' = 'overall'
        '7 Days' = '7days'
        '1 Month' = '1month'
        '3 Months' = '3month'
        '6 Months' = '6month'
        '1 Year' = '12month'
    }

    $callingCommand = (Get-PSCallStack)[-2].Command
    if ($callingCommand -like 'Get-LFM*Info') { $lfmParameter['Username'] = 'username' }
    if ($callingCommand -like 'Remove-LFM*Tag') { $lfmParameter['Tag'] = 'tag' }

    if ($InputObject.ContainsKey('Timestamp')) { $InputObject['Timestamp'] = (ConvertTo-UnixTime -Date $Timestamp) }
    if ($InputObject.ContainsKey('StartDate')) { $InputObject['StartDate'] = (ConvertTo-UnixTime -Date $StartDate) }
    if ($InputObject.ContainsKey('EndDate')) { $InputObject['EndDate'] = (ConvertTo-UnixTime -Date $EndDate) }
    if ($InputObject.ContainsKey('TimePeriod')) { $InputObject['TimePeriod'] = $period[$InputObject['TimePeriod']] }

    $null = if ($InputObject.ContainsKey('Method')) { $InputObject.Remove('Method') }
    $null = If ($InputObject.ContainsKey('SharedSecret')) { $InputObject.Remove('SharedSecret') }
    $null = If ($InputObject.ContainsKey('PassThru')) { $InputObject.Remove('PassThru') }

    $hash = @{ }
    foreach ($key in $InputObject.Keys) {
        $hash.Add($lfmParameter[$key], $InputObject[$key])
    }

    Write-Output $hash
}
