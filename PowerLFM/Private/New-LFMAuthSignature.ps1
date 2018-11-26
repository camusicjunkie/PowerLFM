function New-LFMAuthSignature {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('auth.getToken','auth.getSession')]
        [string] $Method,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SharedSecret,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Token
    )

    try {
        $sigParams = @{
            'api_key' = $ApiKey
            'method' = $Method
        }

        if ($PSBoundParameters.ContainsKey('Token')) {
            $sigParams.Add('token', $Token)
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
