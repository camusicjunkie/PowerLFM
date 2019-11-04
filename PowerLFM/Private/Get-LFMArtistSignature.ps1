function Get-LFMArtistSignature {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('artist.addTags','artist.removeTag')]
        [string] $Method,

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
            'artist' = $Artist
            'tags' = $Tag
        }

        if ($Method -eq 'artist.removeTag') {
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
