# hMailServer Setup on Windows Server (DC01)

## Objective

Install and configure hMailServer on the Domain Controller to provide IMAP/SMTP services for the lab domain `lab.local`. This enables RainLoop and other email clients to connect and authenticate using Active Directory credentials.

## Prerequisites

- Windows Server 2022 (DC01) running with AD domain `lab.local`
- Static IP: `192.168.200.10`
- RainLoop already installed and accessible at `http://192.168.200.1:8080`
- `Visual C++ Redistributable` installed
- hMailServer installer downloaded from hmailserver.com

---

## Installer Troubleshooting

This section documents workarounds for known installer issues on Windows Server 2022. The hMailServer installer (v5.6.x) is legacy software that attempts to download dependencies from deprecated URLs and uses outdated security protocols. If you encounter the errors described below during installation, complete the corresponding fixes before re-running the installer.

### Error: "Error sending request. A redirect request will change a non-secure to a secure connection"

 - **Cause**: The installer attempts HTTP downloads, but Microsoft/hMailServer servers enforce HTTPS redirection. Windows Server blocks this automatic redirect for security reasons.
- **Solution**:
    - Install Visual C++ Redistributable 2015-2022 (x64) manually: https://aka.ms/vs/17/release/vc_redist.x64.exe
    - Disable IE Enhanced Security Configuration: Server Manager > Local Server > IE Enhanced Security Configuration > Set to Off for Administrators
    - Run the installer as Administrator
- **Note**: With dependencies pre-installed, the installer detects them and skips the download step, avoiding the error.

### Error: "error opening http://download.microsoft.com/.../dotnetx.exe - Status code 404"
- **Cause**: The installer attempts to download .NET Framework 2.0 from a deprecated Microsoft URL that no longer exists.
- **Solution**: Install .NET Framework 3.5 (which includes 2.0 and 3.0) via Windows Features before running the installer.
    - **Open** PowerShell as Administrator
    - **Run**: Install-WindowsFeature Net-Framework-Core
- **Note**: Reboot the VM after installing .NET Framework to ensure proper registration.

> After applying the relevant fixes above, re-run the hMailServer installer. The installation should proceed without attempting failed downloads. *May also need machine reboot*.

---

## Installation Steps

### 1. Download hMailServer
- Visit https://www.hmailserver.com/download
- Download a version 5.6.8 ou 5.6.9 - *hMailServer is no longer being actively developed or maintained.*

### 2. Run the Installer
On **DC01**, run the installer as Administrator:
- **Choose Data Folder:** Default `C:\Program Files (x86)\hMailServer\Database`
- **Select Components:** Keep defaults (Full installation: Server, Administrative tools)
- **Database:** Select **Built-in (Microsoft SQL Compact)** - sufficient for lab
- **Administrator Password:** *Set a strong password*

Complete the installation. The hMailServer Administrator GUI will open automatically.

---

## Configuration

### 3. Connect to hMailServer Administrator

- **Host:** `localhost`
- **Password:** *(the password set during installation)*

### 4. Add Domain

1. Right-click **Domains --> Add new domain**
2. **Domain name:** `lab.local`
3. **Enabled:** *Checked*
4. Click **Save**

### 5. Add Mail Account

1. Expand `lab.local` -> **Accounts** -> **Add new account**
2. **Address:** `carlos.silva`@`lab.local`
3. **Password:** `P@ssw0rd123` (or match AD password)
4. **Enabled:** *Checked*
5. Click **Save**

Repeat for other users.

### 6. Configure IP Ranges (Allow External Connections) - May Already Be Configured by Default
By default, hMailServer may already accept external connections. Verify these settings to ensure RainLoop (running on laptop 192.168.200.1) can connect.

1. In hMailServer Administrator, go to **Settings** → **Advanced** → **IP Ranges**
2. Check if **Internet** range already exists with the following default settings:
   - **Lower IP:** `0.0.0.0`
   - **Upper IP:** `255.255.255.255`
   - **Allow connections:** ✅ SMTP, ✅ IMAP (should be checked by default)
   - **Require authentication:** ✅ SMTP, ✅ IMAP (should be checked by default to prevent open relay)
3. If settings differ from above, edit the Internet range to match
4. Click **Save**

> If the connection still fails, check the logs for "Client connection from ... was not accepted" and ensure no conflicting IP range is blocking your laptop's IP (`192.168.200.1`).

### 7. Configure Active Directory Integration (Optional - Not configured)

To authenticate against AD instead of local hMailServer passwords:

1. In hMailServer Administrator, go to **Settings** -> **Advanced** -> **Authentication**
2. Check **Use Active Directory Authentication**
3. Configure:
    - **AD Domain:** `lab.local`
    - **AD Server:** `192.168.200.10`
    - **Use SSL:** *Uncheck* (lab only)

*Note: This requires AD accounts to have the same email address as their login.*

---

## Network Configuration

### 8. Allow IMAP/SMTP in Windows Firewall

On **DC01**, open **Windows Firewall** and allow inbound connections for:
- **IMAP:** Port `143`
- **SMTP:** Port `587`

```powershell
New-NetFirewallRule -DisplayName "Allow IMAP" -Protocol TCP -LocalPort 143 -Direction Inbound -Action Allow
New-NetFirewallRule -DisplayName "Allow SMTP" -Protocol TCP -LocalPort 587 -Direction Inbound -Action Allow
```

### 9. Start hMailServer Service

Ensure the service is running:
```powershell
Get-Service hMailServer
Start-Service hMailServer
Set-Service hMailServer -StartupType Automatic
```

---

## Testing

### 10. Local Test (on DC01)

Open **PowerShell** and test IMAP connection:

```powershell
Test-NetConnection -ComputerName localhost -Port 143
Test-NetConnection -ComputerName localhost -Port 587
```

Should now `TcpTestSucceded: True`: 

```text
ComputerName     : localhost                                                                                            RemoteAddress    : 127.0.0.1
RemotePort       : 143
InterfaceAlias   : Loopback Pseudo-Interface 1
SourceAddress    : 127.0.0.1
TcpTestSucceeded : True



PS C:\Windows\system32> Test-NetConnection -ComputerName localhost -Port 587
WARNING: TCP connect to (::1 : 587) failed


ComputerName     : localhost
RemoteAddress    : 127.0.0.1
RemotePort       : 587
InterfaceAlias   : Loopback Pseudo-Interface 1
SourceAddress    : 127.0.0.1
TcpTestSucceeded : True
```

### 11. Remote Test (from laptop)

On the laptop (PowerShell):
```powershell
Test-NetConnection -ComputerName 192.168.200.10 -Port 143
Test-NetConnection -ComputerName 192.168.200.10 -Port 587
```

Both should succeed. If not, verify firewall and IP ranges.

---

## RainLoop Configuration Update

After hMailServer is running, configure RainLoop domain as follows (note: short login must be disabled due to compatibility issues with the RainLoop image used):

- **IMAP Server**: 192.168.200.10
- **IMAP Port**: 143
- **IMAP Secure**: None
- **IMAP Short Login**: ❌ Unchecked (users must use full email address)
- **SMTP Server**: 192.168.200.10
- **SMTP Port**: 587
- **SMTP Secure**: None
- **SMTP Short Login**: ❌ Unchecked
- **SMTP Authentication**: ✅ Checked

> **Why disable short login?** The RainLoop image (`ghcr.io/xrstf/rainloop`) does not correctly append the domain when `short_login = On`. Disabling it forces users to log in with the full email address (`carlos.silva@lab.local`), which hMailServer requires.

---

## Verification

1. Navigate to RainLoop: `http://192.168.200.1:8080`
2. Login with:
    - **Email:** `carlos.silva@lab.local` (full email required)
    - **Password:** `P@ssw0rd123`
3. Should see the inbox (empty initially)

---

## Troubleshooting

### Logging Configuration
Ensure logging is enabled in hMailServer Administrator to capture errors:
- In hMailServer Administrator, go to **Settings** > **Logging**
- Check Enabled
- Select log types: **Application**, **SMTP**, **IMAP**, **TCP/IP**, **Debug**
- Click **Save**

Log files are stored at: `C:\'Program Files (x86)\hMailServer\Logs\`

View recent logs in PowerShell, this command helps identify session errors, authentication failures, and connection issues:
```powershell
Get-Content "C:\Program Files (x86)\hMailServer\Logs\hmailserver_*.log" -Tail 50
```

| Issue | Possible Fix |
| - | - |
| Can't connect to server | Check firewall rules on DC01; verify service is running |
| Authentication failed | Ensure account exists in hMailServer; if using AD auth, verify AD credentials |
| Connection refused | hMailServer may not be listening; run `netstat -an \| findstr "143"` - should show `0.0.0.0:143` |
| "Too many invalid logon attempts" | hMailServer auto-banned your IP. Restart the service or remove the IP range entry. |
| Session errors or unknown failures | Check hMailServer logs; ensure logging is enabled in Settings > Logging |