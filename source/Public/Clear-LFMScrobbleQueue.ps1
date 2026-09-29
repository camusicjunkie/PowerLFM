function Clear-LFMScrobbleQueue {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    # -SkipIfAbsent so a machine that has never queued anything is not given a queue lock
    # on its way to being told no queue was found.
    $result = Update-LFMScrobbleQueue -SkipIfAbsent -Change {
        param ($Scrobbles, $Save)

        $count = @($Scrobbles).Count
        if ($count -eq 0) {
            Write-Verbose $localizedData.scrobbleQueueEmpty
            return
        }

        # High impact, and deliberately so: every entry is a play that exists nowhere
        # else, so discarding one destroys listening history rather than a cached copy.
        #
        # Prompted inside the Queue Update, because the count it names is only known once
        # the queue has been read under the hold. Another session asking to write while
        # the user reads the prompt backs off rather than blocking.
        if ($PSCmdlet.ShouldProcess("$count pending scrobbles", 'Discarding')) {
            & $Save @()
            Write-Verbose $localizedData.scrobbleQueueCleared
        }
    }

    switch ($result) {
        # Not "the queue is empty": the test for a queue file is made before the hold is
        # taken, so all this can honestly report is that it found none. Another session
        # creating the first Pending Scrobble in between would make the stronger claim a
        # false one, and a user who trusts it would not run the Clear again.
        'Absent' { Write-Verbose $localizedData.scrobbleQueueAbsent }
        'Contended' {
            # Warned rather than merely noted, unlike a contended Flush: the user asked for
            # this and confirmed it, so silence would read as a queue that was discarded.
            # Nobody else is going to do it for them either - a Flush left to another
            # session still gets sent, but a Clear left to one never happens.
            Write-Warning $localizedData.scrobbleQueueClearSkipped
        }
    }
}
