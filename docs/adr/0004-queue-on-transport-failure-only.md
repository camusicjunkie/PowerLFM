# Queue on transport failure only, never on an HTTP response

`Invoke-LFMApiUri` classifies a failure as `PowerLFM.NetworkUnavailable` only when no HTTP
response was received at all — DNS failure, connection refused, timeout. Any response,
including 5xx and 429, throws as it always has.

A 5xx may mean Last.fm accepted the scrobble and then failed on the way out. Queueing it
would resubmit it later, and Last.fm does not promise to deduplicate identical
artist/track/timestamp triples, so the user's play counts would silently inflate. The
asymmetry decides it: queueing too eagerly corrupts listening history invisibly, while
queueing too conservatively loses a play in a rare case — which is exactly what happened
before the queue existed.

## Consequences

- A Last.fm outage returning 503 produces a hard error rather than a queued scrobble. This
  looks like a gap and is not.
- All other callers of `Invoke-LFMApiUri` are unaffected: the new error id is additive and
  only `Set-LFMTrackScrobble` catches it.
