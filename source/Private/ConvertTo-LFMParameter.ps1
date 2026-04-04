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
        'Tag'         = 'tag'
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
        '7 Days' = '7day'
        '1 Month' = '1month'
        '3 Months' = '3month'
        '6 Months' = '6month'
        '1 Year' = '12month'
    }

    $callingCommand = (Get-PSCallStack)[-2].Command
    if ($callingCommand -like 'Get-LFM*Info') { $lfmParameter['UserName'] = 'username' }
    if ($callingCommand -like 'Add-LFM*Tag') { $lfmParameter['Tag'] = 'tags' }

    if ($InputObject.ContainsKey('Timestamp')) { $InputObject['Timestamp'] = (ConvertTo-UnixTime -Date $InputObject['Timestamp']) }
    if ($InputObject.ContainsKey('StartDate')) { $InputObject['StartDate'] = (ConvertTo-UnixTime -Date $InputObject['StartDate']) }
    if ($InputObject.ContainsKey('EndDate')) { $InputObject['EndDate'] = (ConvertTo-UnixTime -Date $InputObject['EndDate']) }
    if ($InputObject.ContainsKey('TimePeriod')) { $InputObject['TimePeriod'] = $period[$InputObject['TimePeriod']] }

    if ($InputObject.ContainsKey('Method')) { $null = $InputObject.Remove('Method') }
    if ($InputObject.ContainsKey('SharedSecret')) { $null = $InputObject.Remove('SharedSecret') }
    if ($InputObject.ContainsKey('PassThru')) { $null = $InputObject.Remove('PassThru') }

    $hash = @{ }
    foreach ($key in $InputObject.Keys) {
        $hash.Add($lfmParameter[$key], $InputObject[$key])
    }

    Write-Output $hash
}
