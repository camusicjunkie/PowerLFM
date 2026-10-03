function Request-LFMToken {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SharedSecret
    )

    $credentials = @{ ApiKey = $ApiKey; SharedSecret = $SharedSecret }

    Write-Verbose ($localizedData.tokenRequest -f $baseUrl)
    $token = (Invoke-LFMApiMethod -Method 'auth.getToken' -Credentials $credentials).Token

    Write-Verbose ($localizedData.tokenAuthorizing)
    Show-LFMAuthWindow -Url "http://www.last.fm/api/auth/?api_key=$ApiKey&token=$token"

    $obj = [pscustomobject] @{
        'ApiKey' = $ApiKey
        'Token' = $token
        'SharedSecret' = $SharedSecret
    }
    Write-Output $obj
}
