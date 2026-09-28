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

        # Positions rather than entries throughout: an entry leaves the queue by having
        # the queue rebuilt without its position, which keeps the survivors in order.
        #
        # The queue outlives the session that wrote it, so a play captured under other
        # credentials is left alone: submitting it would write it to someone else's
        # listening history.
        $allPositions = @(0..($Scrobbles.Count - 1))
        $minePositions = $allPositions.Where({ $Scrobbles[$_].SessionKeyFingerprint -eq $fingerprint })
        $foreignPositions = $allPositions.Where({ $Scrobbles[$_].SessionKeyFingerprint -ne $fingerprint })

        if ($foreignPositions.Count -gt 0) {
            Write-Warning ($localizedData.warningScrobbleQueueForeign -f $foreignPositions.Count)
        }

        if ($minePositions.Count -eq 0) { return }

        # Named so -WhatIf answers what would be sent, not merely how much of it, for a
        # queue whose contents the user has long since forgotten. Prompted inside the
        # Queue Update, because the span it names is only known once the queue has been
        # read under the hold.
        $timestamps = $minePositions.ForEach({ $Scrobbles[$_].Timestamp })
        $oldest = ConvertFrom-UnixTime -UnixTime ($timestamps | Measure-Object -Minimum).Minimum -Local
        $newest = ConvertFrom-UnixTime -UnixTime ($timestamps | Measure-Object -Maximum).Maximum -Local
        $target = $localizedData.scrobbleQueueTarget -f $minePositions.Count, $oldest, $newest

        if (-not $PSCmdlet.ShouldProcess($target, 'Submitting to Last.fm')) {
            return
        }

        $accounted = [Collections.Generic.HashSet[int]]::new()
        $submitted = 0
        $index = 0

        while ($index -lt $minePositions.Count) {
            $size = [math]::Min($scrobbleQueueBatchSize, $minePositions.Count - $index)
            $batchPositions = @($minePositions[$index..($index + $size - 1)])

            try {
                $results = @(Send-LFMScrobbleBatch -Scrobble @($batchPositions.ForEach({ $Scrobbles[$_] })))
            }
            catch {
                # Whatever went wrong, the unsent entries stay queued in order. Losing
                # them is the one outcome the queue exists to prevent.
                Write-Error -ErrorRecord $_
                break
            }

            # Without one result per submitted play there is no way to tell which were
            # taken, so the whole batch is left queued rather than guessed at.
            if ($results.Count -ne $batchPositions.Count) {
                Write-Error ($localizedData.scrobbleQueueFlushFailed -f
                    ($localizedData.errorScrobbleQueueResponse -f $batchPositions.Count, $results.Count))
                break
            }

            for ($position = 0; $position -lt $batchPositions.Count; $position++) {
                $entry = $Scrobbles[$batchPositions[$position]]
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

                $null = $accounted.Add($batchPositions[$position])
            }

            # Committed per batch, not at the end, so a process killed mid-flush cannot
            # resubmit plays Last.fm has already accepted.
            & $Save @($allPositions.Where({ -not $accounted.Contains($_) }).ForEach({ $Scrobbles[$_] }))

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
