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
        $credentials = @{ ApiKey = $ApiKey; SharedSecret = $SharedSecret }
        $irm = Invoke-LFMApiMethod -Method 'auth.getSession' -Parameter @{ Token = $Token } -Credentials $credentials

        $obj = [pscustomobject] @{
            'ApiKey' = $ApiKey
            'SessionKey' = $irm.Session.Key
            'SharedSecret' = $SharedSecret
        }
        Write-Output $obj
    }
}
