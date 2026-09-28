function Test-LFMNetworkUnavailable {
    [CmdletBinding()]
    [OutputType('System.Boolean')]
    param (
        [Parameter(Mandatory)]
        [ErrorRecord] $ErrorRecord
    )

    # Types are compared by name rather than by type literal: HttpResponseException
    # only exists on PowerShell 6+, and referencing it on 5.1 would itself throw.
    $exceptionTypes = @()
    $exception = $ErrorRecord.Exception
    while ($null -ne $exception) {
        $exceptionTypes += $exception.GetType().FullName
        $exception = $exception.InnerException
    }

    # An error body, a response object, or an HttpResponseException all mean Last.fm
    # answered. HttpResponseException derives from HttpRequestException, so it has to
    # be ruled out before the transport types below are considered.
    $hasResponse = $null -ne $ErrorRecord.ErrorDetails -or
                   $null -ne $ErrorRecord.Exception.Response -or
                   $exceptionTypes -contains 'Microsoft.PowerShell.Commands.HttpResponseException'

    if ($hasResponse) {
        return $false
    }

    $transportTypes = @(
        'System.Net.Http.HttpRequestException'
        'System.Net.WebException'
        'System.Net.Sockets.SocketException'
        'System.Threading.Tasks.TaskCanceledException'
        'System.TimeoutException'
    )

    [bool] ($exceptionTypes | Where-Object { $_ -in $transportTypes })
}
