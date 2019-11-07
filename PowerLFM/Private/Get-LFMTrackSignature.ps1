function Get-LFMTrackSignature {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('track.addTags','track.removeTag',
                     'track.love','track.unlove',
                     'track.updateNowPlaying', 'track.scrobble')]
        [string] $Method,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [double] $Timestamp,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Tag,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int] $TrackNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int] $Duration
    )
    try {
        $sigParams = @{
            'method' = $Method
            'api_key' = $LFMConfig.ApiKey
            'sk' = $LFMConfig.SessionKey
        }

        $null = $PSBoundParameters.Remove('Method')

        $convertedParams = ConvertTo-LFMParameter $PSBoundParameters
        $query = New-LFMApiQuery ($convertedParams + $sigParams)

        Get-Md5Hash -String "$query$($LFMConfig.SharedSecret)"
        Write-Verbose "$query$($LFMConfig.SharedSecret)"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
