# Setup runbook: Last.fm credentials and SecretStore

Sets up everything PowerLFM needs before its first call: a Last.fm API account, a Session
Key, and a SecretStore vault holding the three Credentials (`LFMApiKey`, `LFMSessionKey`,
`LFMSharedSecret`). See [ADR 0001](adr/0001-secretstore-for-credentials.md) for why the
Credentials live in a vault and not a file.

**Platform:** PowerShell 7 on Windows, macOS or Linux. Step 5 opens your default browser to
approve the application. If no browser can be opened or the page cannot call back to
PowerShell (headless, SSH), it prints the address and waits for you to press Enter.

## 1. Install the prerequisites

Installing PowerLFM from the Gallery pulls in both vault modules as dependencies. If you are
running from source, install them yourself:

```powershell
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -Scope CurrentUser
```

## 2. Check the vault is registered

PowerLFM reads and writes a vault named exactly `Microsoft.PowerShell.SecretStore`.

```powershell
Get-SecretVault
```

If that name is missing, register it:

```powershell
Register-SecretVault -Name Microsoft.PowerShell.SecretStore -ModuleName Microsoft.PowerShell.SecretStore
```

A vault registered under any other name will not be found.

## 3. Configure vault authentication

Pick one. This decides how often you are prompted.

**Password (recommended).** Nothing can read the vault without the password. Use
`-Interaction None` so scripts fail fast instead of hanging on a prompt.

```powershell
Set-SecretStoreConfiguration -Authentication Password -Interaction None
```

You are asked to create the password. In any session where the vault is locked, including
unattended ones, unlock it before PowerLFM loads its Configuration:

```powershell
Unlock-SecretStore -Password (Read-Host 'Vault password' -AsSecureString)
```

**None.** No prompts, but the vault is protected only by your Windows account. Reasonable
on a personal single-user machine, weak anywhere else.

```powershell
Set-SecretStoreConfiguration -Authentication None -Interaction None
```

## 4. Create the Last.fm API account

1. Sign in to Last.fm, then open <https://www.last.fm/api/account/create>.
2. Name the application, for example `PowerLFM (<your username>)`, and add a description.
3. Leave the callback URL blank. The token flow does not use one.
4. Submit. Last.fm shows an **API key** and a **Shared secret**. Keep them somewhere safe;
   the Shared Secret signs every write, so treat it like a password.

## 5. Authorize and store the Credentials

Read the keys without leaving them in your PSReadLine history, then run the whole flow.
The commands take plain strings, so the Shared Secret is converted just for this call.

```powershell
$apiKey = Read-Host 'API key'
$secure = Read-Host 'Shared secret' -AsSecureString
$sharedSecret = [System.Net.NetworkCredential]::new('', $secure).Password

Request-LFMToken -ApiKey $apiKey -SharedSecret $sharedSecret | Request-LFMSession | Add-LFMConfiguration

Remove-Variable apiKey, secure, sharedSecret
```

What happens:

1. `Request-LFMToken` asks Last.fm for a Token and opens a browser window.
2. Log in if prompted and click **Yes, allow access**. The window closes itself.
3. `Request-LFMSession` exchanges the Token for a Session Key. The Token is valid for 60
   minutes and is single-use.
4. `Add-LFMConfiguration` writes all three Credentials to the vault. If any already exist it
   asks before overwriting each one.

## 6. Verify

```powershell
Get-SecretInfo -Name LFM*          # expect LFMApiKey, LFMSessionKey, LFMSharedSecret
Get-LFMConfiguration               # loads them into this session
Get-LFMUserInfo -User <your username>
```

If `Get-LFMUserInfo` returns your profile, setup is done. Each new PowerShell session needs
`Get-LFMConfiguration` again.

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| Prompted for the vault password, or `Get-Secret` fails in a script | The vault is locked. Run `Unlock-SecretStore` first (step 3). |
| `Request-LFMSession` errors about the token | The Token expired (60 minutes) or was never approved. Run `Request-LFMToken` again and approve in the browser. |
| Browser does not open, or PowerShell keeps waiting after you approve | Open the address PowerShell printed yourself, approve, then press Enter. If it still fails, re-run step 5. |
| Secrets not found although you stored them | The vault name differs from `Microsoft.PowerShell.SecretStore`. Check `Get-SecretVault` (step 2). |
| Writes (love, scrobble, tag) fail with a signature error | The Shared Secret stored is wrong. Re-run step 5 and accept the overwrite prompts. |

## Rotating or removing Credentials

- **New Session Key:** re-run step 5. Overwrite prompts appear for each existing secret.
- **Remove everything:** `Remove-LFMConfiguration` deletes every `LFM*` secret from the vault.
  To revoke access on Last.fm's side as well, remove the application from
  <https://www.last.fm/settings/applications>.
