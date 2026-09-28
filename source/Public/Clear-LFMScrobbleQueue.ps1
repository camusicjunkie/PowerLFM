function Clear-LFMScrobbleQueue {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'High')]
    param ()

    # -SkipIfAbsent so a machine that has never queued anything is not given a queue lock
    # on its way to being told the queue is empty.
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
        'Absent'    { Write-Verbose $localizedData.scrobbleQueueEmpty }
        'Contended' { Write-Verbose $localizedData.scrobbleQueueClearSkipped }
    }
}
