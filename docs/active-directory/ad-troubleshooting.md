# Active Directory - Troubleshooting Guide

## Purpose

Document common issues encountered during Active Directory setup and configuration in a home lab, with practical solutions and verification steps.

## Scope

This guide covers issues related to:
- Domain Controller installation and promotion
- Network connectivity and DNS
- Client domain join
- Group Policy application
- Wazuh integration with AD

---

## 1. Domain Controller Installation Issues

### Issue 1.1: Server Core instead of Desktop Experience

**Symptom:** After installation, you see only a command prompt (SConfig), no graphical interface.

**Root cause:** During VirtualBox VM creation, the OS Edition was set to "Windows Server 2022 Standard Evaluation" (Core) instead of "Windows Server 2022 Standard Evaluation (Desktop Experience)".

**Solution:**
1. Delete the VM
2. Create a new VM, selecting **"Windows Server 2022 Standard Evaluation (Desktop Experience)"** in the OS Edition dropdown
3. Proceed with normal installation

**Prevention:** Always verify the OS Edition in VirtualBox VM creation wizard before clicking Finish.

---

### Issue 1.2: Unable to configure static IP in SConfig

**Symptom:** When trying to set a static IP, SConfig keeps asking for IP address repeatedly without applying.

**Root cause:** SConfig expects you to type **S** (for Static) first, then the IP address.

**Solution:**
1. Select option **8** (Network settings)
2. Choose the correct adapter
3. When prompted **"Select (D)HCP or (S)tatic IP address"**:
   - Type **S** (capital S)
   - Press Enter
   - Now enter the IP address

**Verification:**
```powershell
ipconfig
# Should show your static IP (e.g., 192.168.200.10)
```

---

## 2. Network Connectivity Issues

### Issue 2.1: Cannot ping Domain Controller from other devices

**Symptom:** Ping from client machines to DC times out, but DC can ping clients.

**Root cause:** Windows Firewall blocks ICMP (ping) by default.

**Solution:**
```powershell
# On DC01, create firewall rule to allow ICMP
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

**Alternative:** Use the lab script:
```powershell
.\allow-icmp-ping.ps1
```

---

### Issue 2.2: DNS resolution fails for lab.local

**Symptom:** `nslookup lab.local` returns "Server: UnKnown" or "Non-existent domain".

**Root cause:** Client DNS not pointing to the DC, or DC DNS not configured correctly.

**Solution:**
1. Verify client DNS is set to DC IP (192.168.200.10)
2. On DC01, verify DNS zones:
```powershell
Get-DnsServerZone | Format-Table ZoneName, ZoneType
# Should show lab.local and _msdcs.lab.local
```
3. If zones missing, restart DNS service:
```powershell
Restart-Service DNS
```

---

## 3. Domain Join Issues

### Issue 3.1: "The specified domain either does not exist or could not be contacted"

**Symptom:** When trying to join domain, error appears stating domain cannot be found.

**Causes:**
- DNS not pointing to DC
- Network connectivity issues
- Firewall blocking

**Troubleshooting steps:**
1. Verify DNS settings: `ipconfig /all`
2. Test connectivity: `ping 192.168.200.10`
3. Test DNS resolution: `nslookup lab.local`
4. Test DC discovery: `nltest /dsgetdc:lab.local`

**Solution:**
- Ensure client DNS points to DC (192.168.200.10)
- Check network adapter is on same subnet
- Temporarily disable firewall for testing

---

### Issue 3.2: "Access is denied" when joining domain

**Symptom:** Authentication fails when trying to join domain.

**Causes:**
- Using wrong credentials
- User lacks domain join permissions

**Solution:**
1. Use domain administrator: `LAB\Administrator`
2. Or add user to `Domain Admins` group on DC:
```powershell
Add-ADGroupMember -Identity "Domain Admins" -Members "carlos.silva"
```

---

## 4. Group Policy Issues

### Issue 4.1: GPO not applying

**Symptom:** After creating and linking a GPO, settings don't appear on client.

**Troubleshooting:**
1. Force policy update:
```powershell
gpupdate /force
```
2. Check applied policies:
```powershell
gpresult /r
```
3. Verify GPO is linked to correct OU
4. Check Security Filtering - ensure user/computer is in scope

**Common fixes:**
- Wait 90-120 minutes for automatic refresh
- Log off and log back in (some settings require new session)
- Reboot client (some computer policies require restart)

---

### Issue 4.2: GPO applied but settings not visible

**Symptom:** `gpresult /r` shows GPO applied, but wallpaper, drive maps, etc. not working.

**Possible causes:**
- User vs Computer configuration mismatch
- Policy requires logoff/logon
- Policy requires reboot

**Solutions:**
1. For wallpaper/desktop settings: log off and back on
2. For drive maps: open File Explorer or run `net use`
3. Check Event Viewer → Applications and Services Logs → Microsoft → Windows → GroupPolicy → Operational

---

## 5. Wazuh Agent Issues

### Issue 5.1: Wazuh agent shows "Disconnected" in dashboard

**Symptom:** Agent status is red/disconnected despite being installed.

**Troubleshooting:**
1. On DC01, check service:
```powershell
Get-Service Wazuh
```
2. If service is stopped:
```powershell
Start-Service Wazuh
```
3. If service is running but disconnected, check connectivity:
```powershell
ping 192.168.200.2
telnet 192.168.200.2 1514
```
4. Check agent logs: `C:\Program Files (x86)\ossec-agent\ossec.log`

---

### Issue 5.2: Security events not appearing in Wazuh

**Symptom:** Wazuh dashboard shows no Security events from DC01.

**Troubleshooting:**
1. Verify Security Log is enabled:
```powershell
wevtutil gl Security | Select-String "enabled"
```
2. Check ossec.conf has Security log configured:
```xml
<localfile>
  <location>Security</location>
  <log_format>eventchannel</log_format>
</localfile>
```
3. Restart Wazuh agent:
```powershell
Restart-Service Wazuh
```
4. Verify events are being generated:
```powershell
Get-WinEvent -LogName Security -MaxEvents 5
```

---

### Issue 5.3: Custom rules not triggering

**Symptom:** Custom rules (e.g., 60109 for user creation) never fire.

**Troubleshooting:**
1. Verify rule file is in correct directory:
```bash
ls -la /var/ossec/etc/rules/windows/103-new-user-created.xml
```
2. Check rule syntax:
```bash
sudo /var/ossec/bin/wazuh-analysisd -t
```
3. Verify rule is loaded:
```bash
sudo grep -r "60109" /var/ossec/logs/ossec.log
```
4. Restart Wazuh manager:
```bash
sudo systemctl restart wazuh-manager
```

---

## 6. Quick Reference Commands

| Task | Command |
|------|---------|
| Check domain membership | `(Get-ComputerInfo).CsDomain` |
| Verify domain user | `whoami` |
| List AD users | `Get-ADUser -Filter *` |
| List AD groups | `Get-ADGroup -Filter *` |
| Force GPO update | `gpupdate /force` |
| Show applied GPOs | `gpresult /r` |
| Check DNS zones | `Get-DnsServerZone` |
| Test DC discovery | `nltest /dsgetdc:lab.local` |
| Restart Wazuh agent | `Restart-Service Wazuh` |

---

## 7. Prevention Best Practices

- **Document everything** - Keep notes of configurations and changes
- **Take snapshots** - Before major changes, snapshot your VMs
- **Test in isolation** - Verify changes on one system before applying broadly
- **Use scripts** - Automate repetitive tasks (like firewall rules)
- **Check logs** - Always check Event Viewer or Wazuh logs first

---

## 8. Additional Resources

- [Microsoft AD Documentation](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)
- [Wazuh Documentation](https://documentation.wazuh.com/current/index.html)
- [Group Policy Troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/windows-client/group-policy/group-policy-troubleshooting-overview)