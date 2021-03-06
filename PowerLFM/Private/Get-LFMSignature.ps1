function Get-LFMSignature {
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('album.addTags','album.removeTag',
                     'artist.addTags','artist.removeTag',
                     'auth.getToken','auth.getSession',
                     'track.addTags','track.removeTag',
                     'track.love','track.unlove',
                     'track.updateNowPlaying', 'track.scrobble')]
        [string] $Method,

        [string] $Album,
        [string] $Artist,
        [string[]] $Tag,
        [string] $Track,
        [datetime] $Timestamp,
        [int] $TrackNumber,
        [int] $Duration,
        [guid] $Id,
        [switch] $Passthru,
        [string] $ApiKey,
        [string] $SharedSecret,
        [string] $Token
    )

    $sigParams = @{
        'method' = $Method
        'api_key' = $script:LFMConfig.ApiKey
        'sk' = $script:LFMConfig.SessionKey
    }

    $convertedParams = ConvertTo-LFMParameter $PSBoundParameters

    if ($PSBoundParameters.ContainsKey('ApiKey')) {
        $sigParams.Remove('api_key')
        $sigParams.Remove('sk')

        $query = New-LFMApiQuery ($convertedParams + $sigParams)

        Get-Md5Hash -String "$query$($SharedSecret)"
        Write-Verbose "$query$($SharedSecret)"
    }
    else {
        $query = New-LFMApiQuery ($convertedParams + $sigParams)

        Get-Md5Hash -String "$query$($script:LFMConfig.SharedSecret)"
        Write-Verbose "$query$($script:LFMConfig.SharedSecret)"
    }
}
