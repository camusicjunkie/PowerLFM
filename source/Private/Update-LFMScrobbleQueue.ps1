function Update-LFMScrobbleQueue {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    # Says what happened rather than whether it worked: 'Updated' if the change ran,
    # 'Contended' if another session holds the queue, 'Absent' if -SkipIfAbsent was given
    # and there is no queue file. Callers have something different to say for each - an
    # absent queue is empty, a contended one is somebody else's to write - so a boolean
    # would collapse two outcomes that are not the same news.
    #
    # Deliberately a simple function, with no CmdletBinding and no [Parameter()] - either
    # one makes it advanced, and an advanced function brings its own cmdlet runtime. A
    # change calls $PSCmdlet.ShouldProcess on the command that built it, but the operation
    # description is written to the runtime of whatever is executing, so an advanced
    # function here swallows "Performing the operation ..." unless every caller thinks to
    # pass -Verbose through. -WhatIf and -Confirm are unaffected either way.
    [OutputType('System.String')]
    param (
        # Handed the Pending Scrobbles currently queued and a way to commit new ones:
        #
        #     Update-LFMScrobbleQueue -Change { param ($Scrobbles, $Save) & $Save @() }
        #
        # Calling $Save more than once is expected - a Flush commits after every batch, so a
        # process killed part way through cannot resubmit plays Last.fm already accounted
        # for. Never calling it leaves the file untouched, which is how a change declines to
        # write: a duplicate scrobble, a refused confirmation, an empty queue.
        #
        # Anything the change throws propagates. A commit it had already made stands, for
        # the same reason a Flush commits per batch.
        #
        # A change writes to the queue and to the warning, verbose and error streams; it
        # returns nothing, and anything it does emit is discarded so that it cannot be
        # mistaken for the answer to whether the Queue Update ran. A caller that needs a
        # value out of one either builds it before the change runs, as queueing does, or
        # collects into something the change closes over.
        [scriptblock] $Change,

        # For a change that only has work to do when a queue already exists. Without it the
        # lock is taken either way, which is what queueing needs: the first Pending Scrobble
        # on a machine has no file to find.
        [switch] $SkipIfAbsent
    )

    if ($null -eq $Change) {
        throw [Management.Automation.ParameterBindingException]::new($localizedData.errorScrobbleQueueNoChange)
    }

    # The whole read-modify-write, in one place. ADR-0005 requires the exclusive hold and
    # the atomic swap; having each write site sequence them itself made that a convention
    # rather than an invariant.
    if ($SkipIfAbsent -and -not (Test-Path -LiteralPath (Get-LFMScrobbleQueuePath))) {
        return 'Absent'
    }

    $lock = Enter-LFMScrobbleQueueLock
    if ($null -eq $lock) {
        # Contended, not failed. What that is worth saying is the caller's to judge: an
        # append names the track that could not be queued, a Flush leaves the work to
        # whoever holds the queue.
        return 'Contended'
    }

    try {
        $queue = Import-LFMScrobbleQueue

        # Version reaches neither the change nor the write. Import has already migrated the
        # queue forward and Export stamps the current version on the way out, so a change
        # carrying the field could only ever hand back what it was given.
        $save = {
            param ($Scrobbles)

            Export-LFMScrobbleQueue -Queue ([pscustomobject] @{ Scrobbles = @($Scrobbles) })
        }

        $null = & $Change @($queue.Scrobbles) $save

        'Updated'
    }
    finally {
        $lock.Dispose()
    }
}
