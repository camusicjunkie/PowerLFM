function Invoke-LFMApiMethod {
    [CmdletBinding(DefaultParameterSetName = 'Single')]
    param (
        [Parameter(Mandatory)]
        [string] $Method,

        # A command's bound parameters.
        [Parameter(ParameterSetName = 'Single')]
        [System.Collections.IDictionary] $Parameter = @{ },

        # Several sets of parameters sent in one request, under Last.fm's name[i] notation.
        [Parameter(Mandatory, ParameterSetName = 'Batch')]
        [System.Collections.IDictionary[]] $Batch,

        # An API Key and Shared Secret to use in place of the Configuration. Only the
        # authorization exchange passes them, because it runs before one exists.
        [psobject] $Credentials
    )

    # A failure here has to stop the command that asked, whether or not anything up the
    # stack catches it. An error from ThrowTerminatingError only ends the statement in a
    # caller with no try, so the helpers' errors are rethrown, and this function throws
    # its own: once a function has called ThrowTerminatingError, even a later throw from
    # it only ends the statement.
    try {
        if (-not $Credentials) { $Credentials = $script:LFMConfig }

        # Sending an empty api_key would only pass Last.fm's complaint on.
        if ([string]::IsNullOrWhiteSpace($Credentials.ApiKey)) {
            throw ([ErrorRecord]::new(
                [InvalidOperationException]::new($localizedData.errorConfigurationNotLoaded),
                'PowerLFM.ConfigurationNotLoaded',
                'InvalidOperation',
                $Method
            ))
        }

        $kind = $lfmMethod[$Method].Kind

        if ($PSCmdlet.ParameterSetName -eq 'Batch') {
            $request = @{ }
            for ($index = 0; $index -lt $Batch.Count; $index++) {
                $set = ConvertTo-LFMParameter -InputObject $Batch[$index] -Method $Method
                foreach ($name in $set.Keys) {
                    $request["$name[$index]"] = $set[$name]
                }
            }
        }
        else {
            $request = ConvertTo-LFMParameter -InputObject $Parameter -Method $Method
        }

        $request['method'] = $Method
        $request['api_key'] = $Credentials.ApiKey

        if ($kind -eq 'Write') {
            $request['sk'] = $Credentials.SessionKey
        }

        if ($kind) {
            $request['api_sig'] = Get-LFMSignature -Parameter $request -SharedSecret $Credentials.SharedSecret
        }

        $request['format'] = 'json'

        $httpMethod = if ($kind -eq 'Write') { 'Post' } else { 'Get' }
        $query = New-LFMApiQuery -InputObject $request

        # The Session Key is a permanent credential and the Signature is derived from the Shared
        # Secret, so neither is written out. The Shared Secret is never part of the request.
        $shown = foreach ($name in $request.Keys | Sort-Object) {
            $value = if ($name -in 'sk', 'api_sig') { '********' } else { $request[$name] }
            "$name=$value"
        }
        Write-Verbose "$Method $($httpMethod.ToUpper()) $($shown -join '&')"

        Invoke-LFMApiUri -Uri "$baseUrl/?$query" -Method $httpMethod
    }
    catch {
        throw $_
    }
}
