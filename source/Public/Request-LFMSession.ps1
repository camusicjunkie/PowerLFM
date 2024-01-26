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
        $apiParams = @{
            'method' = 'auth.getSession'
            'api_key' = $ApiKey
            'token' = $Token
            'format' = 'json'
        }

        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $apiSig = Get-LFMSignature -Method $apiParams.Method @noCommonParams
        $apiParams.Add('api_sig', $apiSig)

        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"

        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            $obj = [pscustomobject] @{
                'ApiKey' = $ApiKey
                'SessionKey' = $irm.Session.Key
                'SharedSecret' = $SharedSecret
            }
            Write-Output $obj
        }
        catch {
            throw $_
        }
    }
}
