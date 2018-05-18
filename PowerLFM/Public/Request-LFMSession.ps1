function Request-LastFmSession {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        # Parameter help description
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,

        # Parameter help description
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Token,

        # Parameter help description
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $SharedSecret
    )

    begin{
        $baseUrl = 'https://ws.audioscrobbler.com/2.0'
    }
    process {
        try {
            $apiSig = Get-Md5Hash -String "api_key$($ApiKey)methodauth.getSessiontoken$Token$SharedSecret"
            Write-Verbose "Signature MD5 Hash: $apiSig"

            $params = @{
                'Uri' = "$baseUrl/?method=auth.getSession&api_key=$ApiKey&token=$token&api_sig=$apiSig&format=json"
                'ErrorAction' = 'Stop'
            }
            Write-Verbose $params.Uri

            $sessionKey = Invoke-RestMethod @params

            $obj = [PSCustomObject] @{
                'ApiKey' = $ApiKey
                'SessionKey' = $sessionKey.session.key
            }
            Write-Output $obj
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}