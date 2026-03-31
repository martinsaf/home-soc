# RainLoop Short Login Authentication Problem

## Problem

After configuring RainLoop with hMailServer, users are unable to log in. The RainLoop login page shows `Authentication failed` even though the same credentials work via telnet or other email clients. The hMailServer logs show that the login attempts are being sent as `username` without the domain (e.g., `carlos.silva`) instead of `carlos.silva@lab.local`, and the server rejects them with:
```text
TAG2 NO Invalid user name or password. Please use full email address as user name.
```

When the user manually enters the full email address, the login may still fail, or the server may auto-ban the IP due to repeated invalid attempts.

## Environment

- **Mail server:** hMailServer on Windows Server 2022 (DC01), IP `192.168.200.10`
- **Webmail client:** RainLoop running in a Docker container on a Windows laptop (IP `192.168.200.1`)
- **RainLoop image:** `ghcr.io/xrstf/rainloop:v1.17.0`
- **Domain:** `lab.local`
- **Test user:** `carlos.silva` with password `P@ssw0rd123`

## Root Cause

The RainLoop image `ghcr.io/xrstf/rainloop:v1.17.0` has a bug or incompatibility with the `short_login` feature. When `Use short login` is enabled in the domain configuration, RainLoop is expected to automatically append the domain (`@lab.local`) to a username entered without it. However, it fails to do so, sending the raw username (`carlos.silva`) to the IMAP/SMTP server.

hMailServer, by default, requires the full email address as the login identifier. It rejects the short username, causing authentication failure.

Additionally, enabling short login may cause RainLoop to send malformed commands, leading to the server auto‑banning the client IP after several failed attempts.

## Solution

**Disable short login** for both IMAP and SMTP in the RainLoop domain configuration. Users will then be required to enter their full email address (`carlos.silva@lab.local`) on the login screen.

### Step-by-Step Resolution

1. **Access RainLoop admin panel** at `http://192.168.200.1:8080/?admin` (or your lab IP).
2. Go to **Domains** and click on the domain `lab.local` to edit.
3. Under **IMAP Settings**, **uncheck** `Use short login`.
4. Under **SMTP Settings**, **uncheck** `Use short login`.
5. Click **Save**.
6. (Optional) Edit the domain configuration file directly:
```powershell
cd D:\docker-containers\rainloop\data\_data_\_default_\domains
notepad lab.local.ini
```
- Ensure the following lines are present:
    ```ini
    imap_short_login = Off
    smtp_short_login = Off
    ```
7. Restart the RainLoop container:
```powershell
docker-compose restart
```
8. Test login with the full email address: `carlos.silva@lab.local` and the correct password.

## Verification
- hMailServer logs should show a successful `LOGIN` with the full email address.
- RainLoop should display the user's mailbow (inbox) without erros.

## Alternative Solutions
- **Use a different RainLoop image**: The image `hardware/rainloop` or `englbery/rainloop` may handle short login correctly, but they are older and may have other issues. Testing is required.

## Lessons Learned
- Always test authentication using telnet first to isolate the problem (client vs. server).
- RainLoop's `short_login` feature is not reliable across all Docker images. Disabling it forces explicit user input but guarantees compatibility.
- hMailServer logs (`C:\Program Files (x86)\hMailServer\Logs\`) are invaluable for diagnosing authentication issues.
- Clear Auto-ban

## Related Documentation

- [`hMailServer-setup-on-DC01.md`](../email/hMailServer-setup-on-DC01.md)
- [`rainloop-setup.md`](../email/rainloop-setup.md)