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
        'Track'       = 'track'
        'UserName'    = 'user'
        'Token'       = 'token'
        'ApiKey'      = 'api_key'
    }

    $callingCommand = (Get-PSCallStack)[-2].Command
    if ($callingCommand -like 'Get-LFM*Info') {$lfmParameter['Username'] = 'username'}
    if ($callingCommand -like 'Remove-LFM*Tag') {$lfmParameter['Tag'] = 'tag'}

    $null = if ($InputObject.ContainsKey('Method')) {$InputObject.Remove('Method')}
    $null = If ($InputObject.ContainsKey('SharedSecret')) {$InputObject.Remove('SharedSecret')}
    $null = If ($InputObject.ContainsKey('PassThru')) {$InputObject.Remove('PassThru')}

    $hash = @{}
    foreach ($key in $InputObject.Keys) {
        $hash.Add($lfmParameter[$key], $InputObject[$key])
    }

    Write-Output $hash
}
