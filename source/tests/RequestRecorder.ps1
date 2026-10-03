# Fakes Invoke-RestMethod inside PowerLFM and records every request sent through it, so a
# test asserts on the request that went out rather than on calls between private functions.
# Dot-source it, then call Register-LFMFakeRestMethod inside a BeforeAll or It.

function Register-LFMFakeRestMethod {
    param (
        [object] $Response
    )

    $global:LFMFakeRestMethod = @{
        Requests = [System.Collections.Generic.List[object]]::new()
        Response = $Response
    }

    Mock Invoke-RestMethod {
        $global:LFMFakeRestMethod.Requests.Add([pscustomobject] @{
            HttpMethod = [string] $Method
            Uri        = ([uri] $Uri).OriginalString
        })
        $global:LFMFakeRestMethod.Response
    } -ModuleName 'PowerLFM'
}

function Get-LFMRecordedRequest {
    foreach ($request in $global:LFMFakeRestMethod.Requests) {
        $parameters = @{ }
        $query = $request.Uri.Substring($request.Uri.IndexOf('?') + 1)
        foreach ($pair in $query -split '&') {
            $name, $value = $pair -split '=', 2
            $parameters[[uri]::UnescapeDataString($name)] = [uri]::UnescapeDataString($value)
        }

        [pscustomobject] @{
            HttpMethod = $request.HttpMethod
            Method     = $parameters['method']
            Parameters = $parameters
            Uri        = $request.Uri
        }
    }
}
