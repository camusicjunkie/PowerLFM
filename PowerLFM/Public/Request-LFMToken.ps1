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

    $apiParams = @{
        'method' = 'auth.getToken'
        'api_key' = $ApiKey
        'format' = 'json'
    }

    $noCommonParams = Remove-CommonParameter $PSBoundParameters
    $apiSig = Get-LFMSignature -Method $apiParams.Method @noCommonParams
    $apiParams.Add('api_sig', $apiSig)

    $query = New-LFMApiQuery $apiParams
    $apiUrl = "$baseUrl/?$query"

    try {
        Write-Verbose ($script:localizedData.tokenRequest -f $baseUrl)
        $token = (Invoke-LFMApiUri -Uri $apiUrl).Token

        Write-Verbose ($script:localizedData.tokenAuthorizing)
        Show-LFMAuthWindow -Url "http://www.last.fm/api/auth/?api_key=$ApiKey&token=$token"

        $obj = [pscustomobject] @{
            'ApiKey' = $ApiKey
            'Token' = $token
            'SharedSecret' = $SharedSecret
        }
        Write-Output $obj
    } catch {
        throw $_
    }
}
