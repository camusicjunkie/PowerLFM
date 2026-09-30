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

    # Opened by hand rather than through ReadAllText or Get-Content, for three reasons.
    #
    # The encoding: 5.1 reads a file with no byte order mark as ANSI, which mangles every
    # artist name outside ASCII. Naming UTF-8 here makes both hosts agree.
    #
    # The share mode: ReadAllText denies writers for as long as it reads, and a Queue
    # Update commits by swapping the file in. On Windows that swap fails outright against
    # an open reader, so a session merely reading the queue could make another session's
    # commit throw. Allowing Delete lets the swap happen underneath this read, which still
    # sees the queue as it was when it opened - the same Pending Scrobbles a read a moment
    # earlier would have returned.
    #
    # The retry: the swap itself takes the file exclusively for the moment it runs, so the
    # traffic goes both ways. A read that lands in that moment is not a read that failed,
    # it is a read that arrived while somebody was committing, and the queue it wants is
    # there again directly afterwards. Waiting briefly is what reading takes no hold
    # means in practice: readers give way, rather than making a Queue Update wait for
    # them or failing in front of the user because one was in flight.
    $content = $null
    $stopwatch = [Diagnostics.Stopwatch]::StartNew()
    do {
        $reader = $null
        try {
            $stream = [IO.File]::Open(
                $path,
                [IO.FileMode]::Open,
                [IO.FileAccess]::Read,
                [IO.FileShare]::Read -bor [IO.FileShare]::Delete
            )
            try {
                $reader = [IO.StreamReader]::new($stream, [Text.UTF8Encoding]::new($false))
                $content = $reader.ReadToEnd()
            }
            finally {
                if ($null -ne $reader) { $reader.Dispose() } else { $stream.Dispose() }
            }
        }
        catch [IO.IOException] {
            # Out of patience: a queue held this long is not mid-swap, and saying so beats
            # returning an empty queue that reads as "you have nothing pending".
            if ($stopwatch.ElapsedMilliseconds -ge 2000) { throw }
            Start-Sleep -Milliseconds 25
        }
    }
    while ($null -eq $content)

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
