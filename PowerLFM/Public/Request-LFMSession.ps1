function Request-LFMSession {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Token,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $SharedSecret
    )

    process {
        try {
            $sigParams = @{
                'ApiKey' = $ApiKey
                'Method' = 'auth.getSession'
                'SharedSecret' = $SharedSecret
                'Token' = $Token
            }
            $apiSig = Get-LFMAuthSignature @sigParams
            Write-Verbose "Signature MD5 Hash: $apiSig"

            $apiParams = @{
                'method' = 'auth.getSession'
                'api_key' = $APIKey
                'token' = $Token
                'api_sig' = $apiSig
                'format' = 'json'
            }

            #Building string to append to base url
            $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
                "$($_.Name)=$($_.Value)"
            }
            $string = $keyValues -join '&'

            $apiUrl = "$baseUrl/?$string"

            $sessionKey = Invoke-RestMethod -Uri $apiUrl

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
