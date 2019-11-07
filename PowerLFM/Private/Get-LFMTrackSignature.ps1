function Get-LFMTrackSignature {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
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
            #'artist' = $Artist
            #'track' = $Track
        }

        $null = $PSBoundParameters.Remove('Method')

        $convertedParams = ConvertTo-LFMParameter ([hashtable] $PSBoundParameters)
        $query = New-LFMApiQuery -InputObject ($convertedParams + $sigParams)

        #if ($PSBoundParameters.ContainsKey('Tag')) {
        #    if ($Method -eq 'track.removeTag') {
        #        $sigParams.Add('tag', $Tag)
        #    }
        #    else {
        #        $sigParams.Add('tags', $Tag)
        #    }
        #}

        #switch ($PSBoundParameters.Keys) {
        #    'Album' {$sigParams.Add('album', $Album)}
        #    'Id' {$sigParams.Add('mbid', $Id)}
        #    'TrackNumber' {$sigParams.Add('trackNumber', $TrackNumber)}
        #    'Duration' {$sigParams.Add('duration', $Duration)}
        #}
#
        #$keyValues = $sigParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
        #    "$($_.Key)$($_.Value)"
        #}
#
        #$string = $keyValues -join ''

        Get-Md5Hash -String "$query$($LFMConfig.SharedSecret)"
        Write-Verbose "$query$($LFMConfig.SharedSecret)"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
