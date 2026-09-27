# Configuration is module state, not a value passed to each command

Every Last.fm call needs the API Key and Session Key, and PowerLFM exposes over sixty
commands. Threading those through each one as parameters would bury the arguments the user
actually cares about at every call site, so `Get-LFMConfiguration` loads the Credentials into
module state once per PowerShell session and commands read them from there.

## Consequences

- `Get-LFMConfiguration` returns nothing despite its verb: it is a load, not a query. This
  looks like a naming bug and should not be "corrected" without revisiting this decision.
- Commands fail at call time rather than at parse time when Configuration has not been loaded.
- Configuration is per-session, so each new PowerShell session must load it again.
- A single session cannot act as two different Last.fm users at once.
