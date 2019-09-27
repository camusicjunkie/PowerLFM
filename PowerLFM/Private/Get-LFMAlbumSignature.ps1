function Get-LFMAlbumSignature {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('album.addTags','album.removeTag')]
        [string] $Method,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(1,10)]
        [string[]] $Tag
    )
    try {
        $sigParams = @{
            'method' = $Method
            'api_key' = $LFMConfig.ApiKey
            'sk' = $LFMConfig.SessionKey
            'album' = $Album
            'artist' = $Artist
            'tags' = $Tag
        }

        if ($Method -eq 'album.removeTag') {
            $sigParams.Remove('tags')
            $sigParams.Add('tag', $Tag)
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
