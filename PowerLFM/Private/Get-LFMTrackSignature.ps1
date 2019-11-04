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
        [string[]] $Tag,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int] $Duration
    )
    try {
        $sigParams = @{
            'method' = $Method
            'api_key' = $LFMConfig.ApiKey
            'sk' = $LFMConfig.SessionKey
            'artist' = $Artist
            'track' = $Track
        }

        if ($PSBoundParameters.ContainsKey('Tag')) {
            if ($Method -eq 'track.removeTag') {
                $sigParams.Add('tag', $Tag)
            }
            else {
                $sigParams.Add('tags', $Tag)
            }
        }

        switch ($PSBoundParameters.Keys) {
            'Album' {$sigParams.Add('album', $Album)}
            'Id' {$sigParams.Add('mbid', $Id)}
            'Duration' {$sigParams.Add('duration', $Duration)}
        }

        $keyValues = $sigParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
            "$($_.Key)$($_.Value)"
        }

        $string = $keyValues -join ''

        Get-Md5Hash -String "$string$($LFMConfig.SharedSecret)"
        Write-Verbose "$string$($LFMConfig.SharedSecret)"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
