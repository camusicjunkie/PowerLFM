function Wait-LFMAuthorization {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ApiKey,

        [Parameter(Mandatory)]
        [string] $Token,

        [ValidateRange(1, 3600)]
        [int] $TimeoutSeconds = 120
    )

    $url = "https://www.last.fm/api/auth/?api_key=$ApiKey&token=$Token"
    $listener = Open-LFMAuthListener

    try {
        if ($listener) {
            $callback = $listener.Prefixes | Select-Object -First 1
            $url += '&cb=' + [uri]::EscapeDataString($callback)
            $pending = $listener.GetContextAsync()
        }

        try {
            Open-LFMBrowser -Url $url
        }
        catch {
            Write-Warning ($localizedData.authBrowserFailed -f $url)
        }

        if ($listener -and $pending.Wait([timespan]::FromSeconds($TimeoutSeconds))) {
            $response = $pending.Result.Response
            $body = [System.Text.Encoding]::UTF8.GetBytes($localizedData.authCallbackPage)
            $response.ContentType = 'text/plain; charset=utf-8'
            $response.OutputStream.Write($body, 0, $body.Length)
            $response.Close()
            return
        }

        if ($listener) {
            Write-Verbose ($localizedData.authTimedOut -f $TimeoutSeconds)
        }
        $null = Read-Host -Prompt $localizedData.authPressEnter
    }
    finally {
        if ($listener) {
            $listener.Close()
        }
    }
}
