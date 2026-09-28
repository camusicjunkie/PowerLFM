# The Scrobble Queue is migrated on read, in memory, and never rewritten by a reader

ADR-0005 requires a migration rather than a reinterpretation when the on-disk shape changes.
`Convert-LFMScrobbleQueueVersion` is that path: a table of steps keyed by the version each one
migrates away from, walked one version at a time until the queue reaches the version this
module understands.

The migration happens in memory and the file is left exactly as it was found. Reading the
queue takes no lock — `Get-LFMScrobbleQueue` is a report, and making it write would mean an
exclusive handle every time a user asked what was pending — so a reader is in no position to
rewrite the file safely. It does not need to: every write stamps the current version, so the
first Scrobble or Flush after an upgrade persists the new shape. Until then the file stays
readable by the older module that wrote it, which is what makes downgrading survivable.

A queue whose version is *higher* than this module's is refused outright rather than routed
through the same table. There is nothing to migrate: the module cannot know what the shape
became, and guessing would hand Last.fm Pending Scrobbles it would record wrong.

## Consequences

- A migration step is handed the queue at version N and returns it in the shape version N+1
  expects. It describes one shape change and nothing else: the engine stamps the version, so
  a step cannot claim to have landed somewhere it did not.
- A step that throws, or returns nothing, aborts the read and names both the file and the
  step. A half-migrated queue is never returned and never written.
- The step table is a plain hashtable keyed by version. It cannot be an ordered dictionary:
  PowerShell indexes one of those by position, so the step for version 1 would be whichever
  step happened to be written second.
- Reading migrates every time until something writes. Steps must therefore be cheap and
  produce the same result each time they run.
- The step table is empty today. Version 1 is the only shape that has existed, so the engine
  is exercised by tests that supply their own steps rather than by a real migration — which
  is the point: the path has to be proven before the first version bump depends on it.
