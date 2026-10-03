function ConvertTo-LFMParameter {
    [CmdletBinding()]
    param (
        [psobject] $InputObject,

        # With a Method, names come from the tables in prefix.ps1 and values are converted
        # by type. Without one, the old path below guesses from the call stack; it goes
        # once every command describes a Method. See ADR-0008.
        [string] $Method
    )

    if ($PSBoundParameters.ContainsKey('Method')) {
        $rename = $lfmMethod[$Method].Rename
        $ignored = [PSCmdlet]::CommonParameters + [PSCmdlet]::OptionalCommonParameters + 'PassThru'

        $hash = @{ }
        foreach ($key in $InputObject.Keys) {
            if ($key -in $ignored) { continue }

            $name = if ($rename -and $rename.ContainsKey($key)) { $rename[$key] } else { $lfmParameterName[$key] }

            # Dropping an unknown name would send the request without it, and nothing would
            # notice until Last.fm ignored or misread the request.
            if (-not $name) {
                $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
                    [ArgumentException]::new(($localizedData.errorUnknownParameter -f $key, $Method)),
                    'PowerLFM.UnknownParameter',
                    'InvalidArgument',
                    $key
                ))
            }

            $value = $InputObject[$key]
            # By type, so a new parameter of a known type is right without touching this.
            # TimePeriod is the one value Last.fm spells differently by name.
            $hash[$name] = if ($key -eq 'TimePeriod') { $lfmTimePeriod[$value] }
                elseif ($value -is [datetime]) { ConvertTo-UnixTime -Date $value }
                elseif ($value -is [switch] -or $value -is [bool]) { [int] [bool] $value }
                elseif ($value -is [guid]) { $value.ToString() }
                elseif ($value -is [array]) { $value -join ',' }
                else { $value }
        }

        return $hash
    }

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
