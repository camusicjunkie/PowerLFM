function Request-LFMToken {
    # .ExternalHelp PowerLFM.psm1-help.xml

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
        $apiSig = New-LFMAuthSignature @sigParams
        Write-Verbose "Signature MD5 Hash: $apiSig"

        $apiParams = [ordered] @{
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
        $token = Invoke-RestMethod -Uri $apiUrl

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
