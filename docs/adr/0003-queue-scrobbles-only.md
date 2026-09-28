# The Scrobble Queue holds scrobbles only, not other mutations

Every mutating command fails when Last.fm is unreachable, but only `Set-LFMTrackScrobble`
queues. A Scrobble is a historical fact bound to a moment: miss it and it cannot be
reconstructed, because nothing anywhere records that a track was played at 14:32 last
Tuesday. A Tag or a Loved Track is a current-state assertion, so a failed call is simply
repeated later with identical results and nothing is lost.

The queue therefore exists because scrobbles are perishable, not because the network is
unreliable. Extending it to tags and loves would add durable state, locking and a flush
path for operations that need none of it.

## Consequences

- `Add-LFM*Tag`, `Remove-LFM*Tag`, `Set-LFMTrackLove` and `Set-LFMTrackUnlove` keep
  throwing when offline. This is deliberate and should not be "made consistent".
- `Set-LFMTrackNowPlaying` also keeps throwing: Now Playing is transient by definition, so
  a queued one would be meaningless by the time it flushed.
