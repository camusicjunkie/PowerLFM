# The Scrobble Queue is a plain versioned file, not a secret

ADR-0001 keeps Credentials in SecretStore because a Shared Secret on disk in the clear is a
durable, permanently valid credential. Pending Scrobbles are not that: they are artist, track
and timestamp, and nothing in them authorises anything. Putting them in the vault would mean
an unlock prompt just to record a track the user already played, in exactly the situation
where the machine is least likely to be attended.

The Scrobble Queue is therefore versioned JSON at `$env:LOCALAPPDATA\PowerLFM\` on Windows
and `$HOME/.local/share/PowerLFM/` elsewhere, resolved by one private function
(`Get-LFMScrobbleQueuePath`).

Each entry carries an MD5 fingerprint of the Session Key rather than the key itself, so the
file identifies which account captured a play without storing anything that can act as that
account. Entries whose fingerprint doesn't match the loaded Configuration are never
submitted: the queue outlives the session that wrote it, so ADR-0002's guarantee that one
session cannot act as two users doesn't carry across a reconfiguration.

## Consequences

- Listening history sits on disk in the clear. Anyone who can read the user's profile can
  read what they played offline.
- A `Version` field gates every read and write. An unrecognised version refuses both and lets
  the scrobble throw, because being locked out of queueing is recoverable and a mangled queue
  of plays recorded nowhere else is not.
- Writes go through an exclusive lock on a sidecar file and a temp-file-plus-rename, so
  concurrent sessions and interrupted writes cannot corrupt the queue. That sequence lives in
  one private function (`Update-LFMScrobbleQueue`) rather than at each write site: a caller
  describes the change it wants to make to the Pending Scrobbles and never sees the lock.
- Changing the on-disk shape later means bumping the version and writing a migration, not
  reinterpreting whatever is already there.
