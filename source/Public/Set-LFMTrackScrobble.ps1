function Set-LFMTrackScrobble {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    [OutputType('PowerLFM.Track.Scrobble')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [datetime] $Timestamp,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int] $TrackNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int] $Duration,

        [Parameter()]
        [switch] $PassThru
    )

    begin {
        # A queued scrobble would otherwise sit until the user happened to run
        # Send-LFMScrobbleQueue by hand. Reported, never prompted for, never fatal:
        # the caller asked to scrobble a track, not to flush a queue.
        try {
            Send-LFMScrobbleQueue -Confirm:$false -ErrorAction Stop
        }
        catch {
            Write-Verbose ($localizedData.scrobbleQueueFlushFailed -f $_.Exception.Message)
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess("Track: $Track", "Setting track to now playing")) {
            try {
                $irm = Invoke-LFMApiMethod -Method 'track.scrobble' -Parameter $PSBoundParameters

                $code = Get-LFMIgnoredMessage -Code $irm.Scrobbles.Scrobble.IgnoredMessage.Code
                if ($code.Code -ne 0) {
                    if ($null -eq $code.Message) {
                        throw $localizedData.errorFiltered2
                    }
                    else {
                        throw ($localizedData.errorFiltered -f $code.Message)
                    }
                }

                if ($PassThru) {
                    [pscustomobject] @{
                        PSTypeName = 'PowerLFM.Track.Scrobble'
                        Artist = $irm.Scrobbles.Scrobble.Artist.'#text'
                        Album = $irm.Scrobbles.Scrobble.Album.'#text'
                        Track = $irm.Scrobbles.Scrobble.Track.'#text'
                    }
                }
            }
            catch {
                # Only a transport failure queues. Anything Last.fm answered is a real
                # error, and swallowing it would hide it behind a growing queue.
                if ($_.FullyQualifiedErrorId -notlike 'PowerLFM.NetworkUnavailable*') {
                    throw $_
                }

                $queueParams = @{
                    Artist    = $Artist
                    Track     = $Track
                    Timestamp = $Timestamp
                }
                foreach ($optional in 'Album', 'Id', 'TrackNumber', 'Duration') {
                    if ($PSBoundParameters.ContainsKey($optional)) {
                        $queueParams[$optional] = $PSBoundParameters[$optional]
                    }
                }

                $pendingScrobble = Add-LFMPendingScrobble @queueParams

                # Queueing failed and warned about why. A visibly failed scrobble beats
                # a lost one, so the original failure still surfaces.
                if ($null -eq $pendingScrobble) {
                    throw $_
                }

                if ($PassThru) {
                    $pendingScrobble
                }
            }
        }
    }
}
