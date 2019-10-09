function Request-LFMSession {
    # .ExternalHelp PowerLFM-help.xml

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

            $irm = Invoke-LFMApiUri -Uri $apiUrl
            if ($irm.Error) {Write-Output $irm; return}

            $obj = [PSCustomObject] @{
                'ApiKey' = $ApiKey
                'SessionKey' = $irm.Session.Key
                'SharedSecret' = $SharedSecret
            }
            Write-Output $obj
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}
