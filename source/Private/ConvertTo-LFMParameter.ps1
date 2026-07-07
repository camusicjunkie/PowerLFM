function ConvertTo-LFMParameter {
    param (
        [psobject] $InputObject,

        [string] $Method
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
        'TrackNumber' = 'trackNumber'
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

    if (-not $Method -and $InputObject.ContainsKey('Method')) { $Method = $InputObject['Method'] }

    # album/artist/track.getInfo take 'username' while every other method,
    # including user.getInfo, takes 'user'. The addTags methods take a comma
    # delimited 'tags' list while removeTag takes a single 'tag'.
    if ($Method -in 'album.getInfo', 'artist.getInfo', 'track.getInfo') { $lfmParameter['UserName'] = 'username' }
    if ($Method -like '*.addTags') { $lfmParameter['Tag'] = 'tags' }

    if ($InputObject.ContainsKey('Timestamp')) { $InputObject['Timestamp'] = (ConvertTo-UnixTime -Date $InputObject['Timestamp']) }
    if ($InputObject.ContainsKey('StartDate')) { $InputObject['StartDate'] = (ConvertTo-UnixTime -Date $InputObject['StartDate']) }
    if ($InputObject.ContainsKey('EndDate')) { $InputObject['EndDate'] = (ConvertTo-UnixTime -Date $InputObject['EndDate']) }
    if ($InputObject.ContainsKey('TimePeriod')) { $InputObject['TimePeriod'] = $period[$InputObject['TimePeriod']] }

    if ($InputObject.ContainsKey('Method')) { $null = $InputObject.Remove('Method') }
    if ($InputObject.ContainsKey('SharedSecret')) { $null = $InputObject.Remove('SharedSecret') }
    if ($InputObject.ContainsKey('PassThru')) { $null = $InputObject.Remove('PassThru') }

    $hash = @{ }
    foreach ($key in $InputObject.Keys) {
        if (-not $lfmParameter.ContainsKey($key)) {
            throw ($localizedData.errorUnmappedParameter -f $key)
        }

        $value = $InputObject[$key]
        if ($value -is [array]) { $value = $value -join ',' }

        $hash.Add($lfmParameter[$key], $value)
    }

    $hash
}
