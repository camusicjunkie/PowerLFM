# Commands describe a Method; only Invoke-LFMApiMethod builds a request

Every public command used to assemble its own request from five small private functions:
strip the common parameters, rename them, build the query, sign it, send it. The rules that
actually mattered — when to send `sk`, when to sign, GET or POST, which Last.fm name a
parameter takes — lived in 57 hand-copied recipes and one call-stack check, and the bugs
lived in the gaps between them. A command now names a Method and hands over its bound
parameters, and `Invoke-LFMApiMethod` does everything else. Its private helpers are internal
seams: no command and no command test calls them.

Last.fm's quirks are facts about Methods, so they are kept as data keyed by Method rather
than spread across the commands that call them:

- **Signing and POST are decided by the Method.** A write is a signed POST carrying `sk`;
  an `auth.*` Method is a signed GET without it; anything else is an unsigned GET. Only the
  writes and `auth.*` are listed. A write missing from the list goes out unsigned and Last.fm
  refuses it loudly, which is cheaper than maintaining a list of every Method the module uses.
- **Parameter names come from one table with exceptions per Method** (`username` on the
  `*.getInfo` reads, `tags` on `addTags`), never from looking at who called.
- **Values are converted by type, not by parameter name.** A datetime is Unix time, a switch
  is `1` or `0`, a string array is comma-joined. A new datetime parameter is right without
  anyone touching the request code.
- **An unknown parameter name throws.** Dropping it silently would turn a missing table entry
  into a missing parameter on the wire that no test notices. Only the common parameters and
  `PassThru` are removed without complaint.

## Considered options

- **Callers pass switches such as `-Signed -Post`.** Rejected: it keeps a fact about Last.fm
  at every call site, which is the problem being fixed.
- **Commands keep mocking the private pipeline in their tests.** Rejected: those tests pinned
  the order of private calls and asserted nothing about the request sent, which let three
  bugs through. Tests fake `Invoke-RestMethod`, as ADR-0007 already says they do, and assert
  on the request.

## Consequences

- The Signature is computed in exactly one place. The manual pre-release check in ADR-0007
  applies to any change behind `Invoke-LFMApiMethod`, rather than to a list of five files.
- The Signature is proven in `Invoke-LFMApiMethod`'s own tests against fixed known answers,
  not recomputed in the test with the same algorithm, which would pass however wrong it was.
  Command tests only check that a write is a signed POST.
- Batched scrobbles go through the same naming as single ones: the function takes a list of
  parameter sets and writes Last.fm's `name[i]` array notation itself.
- `Invoke-LFMApiMethod` refuses to send anything when no Configuration is loaded, rather than
  sending an empty `api_key` and passing Last.fm's complaint on.
- Its verbose output names the Method and parameters with `sk` and `api_sig` masked. The
  Shared Secret never appears in any stream.
