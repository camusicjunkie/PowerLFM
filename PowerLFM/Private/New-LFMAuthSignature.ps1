function New-LastFmSignature {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,

        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('auth.getToken','auth.getSession',
                     'album.addtags','album.removetag',
                     'artist.addtags','artist.removetag',
                     'track.addtags','track.removetag',
                     'track.love','track.unlove')]
        [string] $Method,

        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SharedSecret
    )

    try {
        $sigParams = @{
            'api_key' = $ApiKey
            'method' = $Method
        }

        $keyValues = $sigParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
            "$($_.Key)$($_.Value)"
        }

        $string = $keyValues -join ''
        Write-Verbose $string

        Get-Md5Hash -String "$string$SharedSecret"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}