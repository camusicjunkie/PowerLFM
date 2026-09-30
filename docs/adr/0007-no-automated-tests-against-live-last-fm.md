# No automated tests against live Last.fm

Nothing in the test suite reaches Last.fm. Every test that exercises a request does it
against a fake standing in for `Invoke-RestMethod`, and the assertion is about the request
this module built — its method, its parameters, its Signature — never about the answer a
real server gave.

The one thing a live call would prove and a fake cannot is that Last.fm accepts a Signature
this module produced. That is worth knowing, but it is worth knowing once per change to the
signing code, not once per push, and the cost of learning it automatically is high:

- A live test needs a real Session Key in CI. A Session Key does not expire, is not scoped
  to a test, and would sit in the repository's secrets for every workflow to reach.
- A Scrobble accepted by Last.fm is recorded permanently on a real user's listening history
  and cannot be withdrawn through the API. A test that runs on every push writes junk into
  an account forever, and a test account is still an account someone has to own.
- Last.fm's availability would become this repository's build status. A red build would
  stop meaning "this change is wrong".

The suite's own stopping rule points the same way: a test earns its place by defending a
claim `CONTEXT.md` makes about this module. "Last.fm is up" is not one of those claims.

## Consequences

- Before tagging a release that changed `Get-LFMSignature`, `New-LFMApiQuery`,
  `ConvertTo-LFMParameter`, `Invoke-LFMApiUri` or `Send-LFMScrobbleBatch`, one Scrobble is
  submitted by hand against a real account and confirmed on the user's listening history.
  Nothing automates this and nothing gates the tag on it.
- A break in how this module signs or shapes a request reaches the PowerShell Gallery if
  that manual check is skipped. Accepted knowingly: the failure is loud, the fix is a
  patch release, and the alternative costs a permanent credential in CI.
- `Send-LFMScrobbleQueue` is the safety net either way. A request Last.fm refuses to
  account for leaves the Pending Scrobbles in the Scrobble Queue rather than dropping them,
  so a signing break delays plays rather than losing them.
- If a `LiveApi` tag is ever introduced, it is excluded from CI by default and this
  decision is what it has to argue with.
