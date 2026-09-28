function Clear-LFMScrobbleQueue {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    $lock = Enter-LFMScrobbleQueueLock
    if ($null -eq $lock) {
        Write-Warning $localizedData.scrobbleQueueFlushSkipped
        return
    }

    try {
        $queue = Import-LFMScrobbleQueue
        $count = @($queue.Scrobbles).Count

        if ($count -eq 0) {
            Write-Verbose $localizedData.scrobbleQueueEmpty
            return
        }

        # High impact, and deliberately so: every entry is a play that exists nowhere
        # else, so discarding one destroys listening history rather than a cached copy.
        if ($PSCmdlet.ShouldProcess("$count pending scrobbles", 'Discarding')) {
            $queue.Scrobbles = @()
            Export-LFMScrobbleQueue -Queue $queue
            Write-Verbose $localizedData.scrobbleQueueCleared
        }
    }
    finally {
        $lock.Dispose()
    }
}
