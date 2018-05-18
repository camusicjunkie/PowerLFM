function Request-LastFmToken {
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
        [string] $SharedSecret
    )

    try {
        $baseUrl = 'https://ws.audioscrobbler.com/2.0'

        $apiSig = New-LastFMSignature -ApiKey $ApiKey -Method auth.getToken -SharedSecret $SharedSecret
        Write-Verbose "Signature MD5 Hash: $apiSig"

        $params = @{
            'Uri' = "$baseUrl/?method=auth.getToken&api_key=$ApiKey&api_sig=$apiSig&format=json"
            'ErrorAction' = 'Stop'
        }
        Write-Verbose $params.uri

        Write-Verbose "Requesting token from $baseUrl"
        $token = Invoke-RestMethod @params

        Write-Verbose "Authorizing application with requested token on account"
        $authUrl = "http://www.last.fm/api/auth/?api_key=$ApiKey&token=$($token.token)"

        $id = Start-Process -FilePath IExplore -ArgumentList $authUrl -PassThru | Select-Object -ExpandProperty Id
        Wait-Process -Id $id

        $obj = [PSCustomObject] @{
            'ApiKey' = $ApiKey
            'Token' = $token.token
            'SharedSecret' = $SharedSecret
        }
        Write-Output $obj
    }
    catch {
        Write-Error $_.Exception.Message
    }
}