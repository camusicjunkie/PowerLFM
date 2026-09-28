function Send-LFMScrobbleQueue {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    param ()

    # -SkipIfAbsent because the common case is an empty queue on a machine that has never
    # been offline, and that should not create a thing on disk.
    $result = Update-LFMScrobbleQueue -SkipIfAbsent -Change {
        param ($Scrobbles, $Save)

        if ($Scrobbles.Count -eq 0) {
            Write-Verbose $localizedData.scrobbleQueueEmpty
            return
        }

        $fingerprint = Get-LFMSessionKeyFingerprint

        # The queue outlives the session that wrote it, so a play captured under other
        # credentials is left alone: submitting it would write it to someone else's
        # listening history.
        $mine = @($Scrobbles.Where({ $_.SessionKeyFingerprint -eq $fingerprint }))
        $foreign = @($Scrobbles).Count - $mine.Count

        if ($foreign -gt 0) {
            Write-Warning ($localizedData.warningScrobbleQueueForeign -f $foreign)
        }

        if ($mine.Count -eq 0) { return }

        # Named so -WhatIf answers what would be sent, not merely how much of it, for a
        # queue whose contents the user has long since forgotten. Prompted inside the
        # Queue Update, because the span it names is only known once the queue has been
        # read under the hold.
        $timestamps = $mine.ForEach({ $_.Timestamp })
        $oldest = ConvertFrom-UnixTime -UnixTime ($timestamps | Measure-Object -Minimum).Minimum -Local
        $newest = ConvertFrom-UnixTime -UnixTime ($timestamps | Measure-Object -Maximum).Maximum -Local
        $target = $localizedData.scrobbleQueueTarget -f $mine.Count, $oldest, $newest

        if (-not $PSCmdlet.ShouldProcess($target, 'Submitting to Last.fm')) {
            return
        }

        # Accounted for by Scrobble Identity, not by position: the queue is rebuilt after
        # every batch, and the survivors are the entries whose identity is not in here,
        # filtered in place so their order is the order they were queued in.
        $accounted = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $submitted = 0
        $index = 0

        while ($index -lt $mine.Count) {
            $size = [math]::Min($scrobbleQueueBatchSize, $mine.Count - $index)
            $batch = @($mine[$index..($index + $size - 1)])

            try {
                $results = @(Send-LFMScrobbleBatch -Scrobble $batch)
            }
            catch {
                # Whatever went wrong, the unsent entries stay queued in order. Losing
                # them is the one outcome the queue exists to prevent.
                Write-Error -ErrorRecord $_
                break
            }

            # Without one result per submitted play there is no way to tell which were
            # taken, so the whole batch is left queued rather than guessed at.
            if ($results.Count -ne $batch.Count) {
                Write-Error ($localizedData.scrobbleQueueFlushFailed -f
                    ($localizedData.errorScrobbleQueueResponse -f $batch.Count, $results.Count))
                break
            }

            for ($position = 0; $position -lt $batch.Count; $position++) {
                $entry = $batch[$position]
                $code = Get-LFMIgnoredMessage -Code $results[$position].IgnoredMessage.Code
                $timestamp = ConvertFrom-UnixTime -UnixTime $entry.Timestamp -Local

                if ($code.Code -eq 0) {
                    $submitted++
                }
                elseif ($code.Code -eq 3) {
                    # Older than Last.fm will take. It can never succeed, and leaving it
                    # queued guarantees the queue never empties, so it goes.
                    Write-Warning ($localizedData.warningScrobbleQueueDropped -f
                        $entry.Artist, $entry.Track, $timestamp, $code.Message)
                }
                else {
                    # Every other reason Last.fm declines may not hold next time - a
                    # daily limit resets, a clock is corrected - so the play stays put.
                    Write-Warning ($localizedData.warningScrobbleQueueNotRecorded -f
                        $entry.Artist, $entry.Track, $timestamp, $code.Message)
                    continue
                }

                $null = $accounted.Add((Get-LFMScrobbleIdentity -Scrobble $entry))
            }

            # Committed per batch, not at the end, so a process killed mid-flush cannot
            # resubmit plays Last.fm has already accepted.
            #
            # The fingerprint is checked as well as the identity because a play captured
            # under other credentials is never this Flush's to remove, whatever it is
            # identical to.
            & $Save @($Scrobbles.Where({
                $_.SessionKeyFingerprint -ne $fingerprint -or
                -not $accounted.Contains((Get-LFMScrobbleIdentity -Scrobble $_))
            }))

            $index += $size
        }

        Write-Verbose ($localizedData.scrobbleQueueFlushed -f $submitted)
    }

    switch ($result) {
        'Absent' { Write-Verbose $localizedData.scrobbleQueueEmpty }
        'Contended' {
            # Another session is already flushing the queue. Nothing to report and nothing
            # to do: whatever this one would have sent, that one is sending.
            Write-Verbose $localizedData.scrobbleQueueFlushSkipped
        }
    }
}
