function Request-LFMToken {
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
        $apiSig = New-LastFMSignature -ApiKey $ApiKey -Method auth.getToken -SharedSecret $SharedSecret
        Write-Verbose "Signature MD5 Hash: $apiSig"

        $irmParams = @{
            'Uri' = "$baseUrl/?method=auth.getToken&api_key=$ApiKey&api_sig=$apiSig&format=json"
            'ErrorAction' = 'Stop'
        }
        
        Write-Verbose "Requesting token from $baseUrl"
        $token = Invoke-RestMethod @irmParams

        Write-Verbose "Authorizing application with requested token on account"
        $authUrl = "http://www.last.fm/api/auth/?api_key=$ApiKey&token=$($token.token)"

        $id = Start-Process -FilePath IExplore -ArgumentList $authUrl -PassThru | Select-Object -ExpandProperty Id
        Write-Warning "Close the browser once $projectName is authorized"
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