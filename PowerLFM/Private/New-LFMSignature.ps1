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

    $sigParams = @{
        'api_key' = $ApiKey
        'method' = $Method
    }

    $keyValues = @()
	$sigParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
        $keyValues += "$($_.Key)$($_.Value)"
        Write-Verbose "$keyValues"
    }

    $string = $keyValues -join ''
    Write-Verbose $string

    Get-Md5Hash -String "$string$SharedSecret"
}