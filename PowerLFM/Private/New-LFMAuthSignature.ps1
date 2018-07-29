function New-LFMAuthSignature {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    [OutputType('System.String')]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,

        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('auth.getToken','auth.getSession')]
        [string] $Method,

        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SharedSecret
    )

    try {
        $sigParams = @{
            'api_key' = $ApiKey
            'method' = $Method
        }

        $keyValues = $sigParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
            "$($_.Key)$($_.Value)"
        }

        $string = $keyValues -join ''

        if ($PSCmdlet.ShouldProcess('Shared secret', 'Creating artist signature')) {
            Get-Md5Hash -String "$string$SharedSecret"
        }
        Write-Verbose "$string$SharedSecret"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
