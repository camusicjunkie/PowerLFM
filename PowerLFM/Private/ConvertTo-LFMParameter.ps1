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
        'Track'       = 'track'
        'UserName'    = 'user'
    }

    $callingCommand = (Get-PSCallStack)[-2].Command
    if ($callingCommand -like 'Get-LFM*Info') {$lfmParameter['Username'] = 'username'}
    if ($callingCommand -like 'Remove-LFM*Tag') {$lfmParameter['Tag'] = 'tags'}

    If ($InputObject.ContainsKey('PassThru')) {$InputObject.Remove('PassThru')}

    $hash = @{}
    foreach ($key in $InputObject.Keys) {
        $hash.Add($lfmParameter[$key], $InputObject[$key])
    }

    Write-Output $hash
}
