function Request-LFMSession {
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

    process {
        try {
            #Need to fix. Add signature function here
            $apiSig = Get-Md5Hash -String "api_key$($ApiKey)methodauth.getSessiontoken$Token$SharedSecret"
            Write-Verbose "Signature MD5 Hash: $apiSig"

            #Need to fix. Dynamically build string with .GetEnumerator()
            $params = @{
                'Uri' = "$baseUrl/?method=auth.getSession&api_key=$ApiKey&token=$token&api_sig=$apiSig&format=json"
                'ErrorAction' = 'Stop'
            }
            $sessionKey = Invoke-RestMethod @params

            $obj = [PSCustomObject] @{
                'ApiKey' = $ApiKey
                'SessionKey' = $sessionKey.session.key
                'SharedSecret' = $SharedSecret
            }
            Write-Output $obj
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}