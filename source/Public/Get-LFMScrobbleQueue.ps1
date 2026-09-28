function Get-LFMScrobbleQueue {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Track.PendingScrobble')]
    param ()

    $queue = Import-LFMScrobbleQueue
    $scrobbles = @($queue.Scrobbles)

    if ($scrobbles.Count -eq 0) {
        Write-Verbose $localizedData.scrobbleQueueEmpty
        return
    }

    # Reading the queue does not require a Configuration. Without one nothing matches,
    # which is the honest answer: nothing here can be submitted as this session stands.
    try {
        $fingerprint = Get-LFMSessionKeyFingerprint
    }
    catch {
        $fingerprint = $null
    }

    $scrobbles | ConvertTo-LFMPendingScrobble -Fingerprint $fingerprint
}
