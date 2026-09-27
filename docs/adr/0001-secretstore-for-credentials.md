# Credentials live in SecretStore, not a file on disk

PowerLFM's Credentials include a Shared Secret that signs every write to Last.fm, so leaving
them in a plaintext file under `$env:APPDATA` — the usual PowerShell module convention —
would put a durable, permanently valid credential on disk in the clear. We depend on
`Microsoft.PowerShell.SecretManagement` and `Microsoft.PowerShell.SecretStore` instead,
because it is the first-party PowerShell answer to this and needs no third-party vault.

## Consequences

- Both modules are `RequiredModules` in the manifest, so installing PowerLFM installs them too.
- Users hit a vault-unlock prompt in any session where the vault is locked, including
  unattended ones. Automation has to unlock the vault before loading Configuration.
- Existing users already have secrets under `LFMApiKey`, `LFMSessionKey` and `LFMSharedSecret`
  in that vault, so moving to a different store now requires a migration path.
