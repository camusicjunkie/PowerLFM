function Import-LFMScrobbleQueue {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param ()

    $path = Get-LFMScrobbleQueuePath

    $emptyQueue = [pscustomobject] @{
        Version   = $scrobbleQueueVersion
        Scrobbles = @()
    }

    if (-not (Test-Path -LiteralPath $path)) {
        return $emptyQueue
    }

    # ReadAllText rather than Get-Content: 5.1 reads a file with no byte order mark as
    # ANSI, which mangles every artist name outside ASCII. This is UTF-8 either way.
    $content = [IO.File]::ReadAllText($path)
    if ([string]::IsNullOrWhiteSpace($content)) {
        return $emptyQueue
    }

    $queue = $content | ConvertFrom-Json

    # An unrecognised version is refused rather than guessed at: being locked out of
    # queueing is recoverable, a mangled queue of plays recorded nowhere else is not.
    if ($queue.Version -ne $scrobbleQueueVersion) {
        throw ($localizedData.errorScrobbleQueueVersion -f $path, $queue.Version)
    }

    # @($null) is a one-element array, so a queue whose Scrobbles came back null would
    # otherwise read as a single empty Pending Scrobble.
    $scrobbles = @()
    if ($null -ne $queue.Scrobbles) {
        $scrobbles = @($queue.Scrobbles)
    }

    [pscustomobject] @{
        Version   = $queue.Version
        Scrobbles = $scrobbles
    }
}
