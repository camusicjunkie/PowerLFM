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

    try {
        $sigParams = @{
            'ApiKey' = $ApiKey
            'Method' = 'auth.getToken'
            'SharedSecret' = $SharedSecret
        }
        $apiSig = Get-LFMAuthSignature @sigParams
        Write-Verbose "Signature MD5 Hash: $apiSig"

        $apiParams = @{
            'method' = 'auth.getToken'
            'api_key' = $APIKey
            'api_sig' = $apiSig
            'format' = 'json'
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"

        Write-Verbose "Requesting token from $baseUrl"
        $token = (Invoke-RestMethod -Uri $apiUrl).Token

        Write-Verbose "Authorizing application with requested token on account"
        Show-LFMAuthWindow -Url "http://www.last.fm/api/auth/?api_key=$ApiKey&token=$token"

        $obj = [PSCustomObject] @{
            'ApiKey' = $ApiKey
            'Token' = $token
            'SharedSecret' = $SharedSecret
        }
        Write-Output $obj
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
