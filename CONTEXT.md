# PowerLFM

A PowerShell module wrapping the Last.fm API. The domain is Last.fm's own: a catalog of
music, a per-user record of what they listened to, and the tags and rankings layered on top.

## Language

### Identity and access

**API Key**:
The public half of a Last.fm application's identity, issued when the application is
registered. Identifies the calling application, not the user.

**Shared Secret**:
The private half of a Last.fm application's identity. Never sent to Last.fm; used only
to sign requests.
_Avoid_: API secret, secret key

**Token**:
A short-lived value that a user authorizes in a browser, proving they consent to the
application acting for them. Exchanged once for a Session Key and then discarded.
_Avoid_: auth token, access token

**Session Key**:
A permanent credential representing one user's authorization of one application. Despite
the name it does not expire and is not tied to any sitting; it is obtained once by
exchanging an authorized Token.
_Avoid_: session, session token

**Credentials**:
The triple of API Key, Session Key and Shared Secret, held durably in the secret vault.
Survives reboots and is shared by every PowerShell session on the machine.
_Avoid_: config, saved configuration, stored settings

**Configuration**:
The Credentials loaded into the current PowerShell session for use by subsequent commands.
Ephemeral: it exists only for the life of that session and must be loaded again in the next
one. This is why the command that establishes it loads rather than returns.
_Avoid_: session config, current credentials

**Signature**:
A hash over a request's parameters and the Shared Secret, proving the request came from an
application that holds the secret. Required on every write and on the authorization exchange.
_Avoid_: api_sig, request hash

### Catalog

**Artist**:
A performer or group in Last.fm's catalog.

**Album**:
A release in Last.fm's catalog, attributed to an Artist.
_Avoid_: release, record

**Track**:
A single recording in Last.fm's catalog, attributed to an Artist and optionally belonging
to an Album.
_Avoid_: song

**Id**:
A MusicBrainz identifier for an Artist, Album or Track. Always the MusicBrainz ID, never a
Last.fm-internal identifier, and always optional: catalog entities are addressable by name
as well.
_Avoid_: mbid, MusicBrainz ID, GUID

**Correction**:
Last.fm's canonical spelling for an Artist or Track name the user supplied loosely. Either
requested explicitly, or applied silently to a request's parameters.
_Avoid_: autocorrect, canonicalization, alias

**Tag**:
A free-text label a user applies to an Artist, Album or Track. Tags are also catalog
entities in their own right, with their own descriptions and rankings.
_Avoid_: label, genre, keyword

**Personal Tag**:
A Tag as applied by one specific user, as opposed to the aggregate of every user's tagging.

### Listening record

**Scrobble**:
A completed play of a Track by a user at a given moment, recorded permanently on that
user's listening history.
_Avoid_: play, listen, play count entry

**Now Playing**:
A transient declaration that a user is currently playing a Track. Not a Scrobble and never
part of the listening history: it is superseded by the next declaration and leaves no
record. Commands that return past listening must exclude it.
_Avoid_: current scrobble, pending scrobble, playing now

**Pending Scrobble**:
A Scrobble captured locally because Last.fm could not be reached, held until it can be
submitted. Unlike a cached value it has no authoritative copy anywhere else: until it is
accepted, the local record is the only one that exists.
_Avoid_: cached scrobble, offline scrobble, queued track

**Scrobble Queue**:
The durable, ordered store of Pending Scrobbles. Outlives the PowerShell session that
created it, so it is not bound to a Configuration and must record which user's Credentials
each Pending Scrobble was captured under.
_Avoid_: scrobble cache, offline cache, backlog

**Session Key Fingerprint**:
A hash of a Session Key, stamped on each Pending Scrobble so the Scrobble Queue records
which user captured it without holding a credential. Comparing it against the loaded
Configuration is what decides whether a Pending Scrobble may be Flushed.
_Avoid_: session hash, account id, owner

**Flush**:
Submitting the Pending Scrobbles in the Scrobble Queue to Last.fm and removing the ones it
accounts for. The single word for this: a Flush is attempted automatically before every
Scrobble and can be run on demand.
_Avoid_: drain, sync, replay, retry

**Ignored Message**:
Last.fm's explanation for a Scrobble it accepted over the wire but silently declined to
record, for example because the Artist is filtered or the timestamp is implausible.
_Avoid_: scrobble error, rejection

**Loved Track**:
A Track a user has explicitly marked as a favourite. Independent of how often they have
scrobbled it.
_Avoid_: favourite, liked track, starred

**Library**:
The set of Artists a user has scrobbled at least once. Membership is earned by listening,
not curated.
_Avoid_: collection, saved artists

### Rankings

**Top <entity>**:
An entity ranked by popularity within some scope: globally, within a country, within a Tag,
or within one user's listening. The scope is what distinguishes one Top list from another;
the ranking itself means the same thing in all of them.
_Avoid_: chart, best, most popular

**Chart**:
A user's or a Tag's play counts over one specific week. Weekly and bounded by definition,
which is what separates a Chart from a Top list.
_Avoid_: global chart, geo chart, ranking, leaderboard

**Chart Period**:
One of the discrete weekly date ranges a Chart can be requested for. Last.fm defines which
weeks exist; they cannot be chosen freely.
_Avoid_: chart list, week, date range
