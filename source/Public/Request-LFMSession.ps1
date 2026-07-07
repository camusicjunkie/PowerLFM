function Request-LFMSession {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
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

        $query = New-LFMApiQuery $apiParams
        $apiUrl = "$baseUrl/?$query"

        $irm = Invoke-LFMApiUri -Uri $apiUrl

        $obj = [pscustomobject] @{
            'ApiKey' = $ApiKey
            'SessionKey' = $irm.Session.Key
            'SharedSecret' = $SharedSecret
        }
        $obj
    }
}
