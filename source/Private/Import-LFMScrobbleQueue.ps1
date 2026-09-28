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

    # An older queue is brought forward in memory and left on disk as it was: reading
    # takes no lock, so it is in no position to rewrite the file. The next write stamps
    # the current version, which is what makes the migration stick. An unrecognised
    # version is still refused rather than guessed at: being locked out of queueing is
    # recoverable, a mangled queue of scrobbles recorded nowhere else is not.
    $queue = Convert-LFMScrobbleQueueVersion -Queue $queue -Path $path

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
