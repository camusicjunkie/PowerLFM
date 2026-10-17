function Open-LFMAuthListener {
    [CmdletBinding()]
    [OutputType('System.Net.HttpListener')]
    param ()

    try {
        # Ask the OS for a free port, release it, then bind the listener to it.
        $probe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
        $probe.Start()
        $port = $probe.LocalEndpoint.Port
        $probe.Stop()

        $listener = [System.Net.HttpListener]::new()
        $listener.Prefixes.Add("http://127.0.0.1:$port/")
        $listener.Start()
        $listener
    }
    catch {
        Write-Verbose ($localizedData.authListenerUnavailable -f $_.Exception.Message)
    }
}
