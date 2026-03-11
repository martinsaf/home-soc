# Detection scenarios implementd

- [SSH brute force detection](https://github.com/martinsaf/home-soc/blob/main/docs/troubleshooting/ssh-bruteforce-attack.md)
- [Agent Disconnected](https://github.com/martinsaf/home-soc/blob/main/docs/troubleshooting/wazuh-agent-disconnected.md)
  > Ideas to do(not done yet):
- [Suspicious execution from tempo folder]()
- [Account creation monitoring]()
- [Privilege escalation detection]()

# local_rules

Custom Wazuh rules for the Home SOC lab.

## How to use

- Each XML file is a single rule or rule group. IDs use range 100100-100199.
- Check rule `sudo /var/ossec/bin/wazuh-analysisd -t`
  - or `wazuh-logtest`
- Deploy to `/var/ossec/etc/rules/` and restart `wazuh-manager`

## Rules included

### /linux

- [100-ssh-bruteforce.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/linux/100-ssh-bruteforce.xml) - SSH brute force detection
- [109-sudo-whoami.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/linux/109-sudo-whoami.xml) - Sudo whoami command execution
- [110-tmp-write.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/linux/110-tmp-write.xml) - File write to /tmp directory

### /windows

- [101-powershell-encoded.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/101-powershell-encoded.xml) - PowerShell encoded command execution
- [102-bruteforce.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/102-bruteforce.xml) - Windows brute force detection
- [103-new-user-created.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/103-new-user-created.xml) - Local user creation
- [104-user-account-changed.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/104-user-account-changed.xml) - User account modification
- [105-user-account-deleted.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/105-user-account-deleted.xml) - User account deletion
- [112-windows-tmp-file.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/112-windows-tmp-file.xml) - File write to Windows temp directory
- [120-ad-user-created.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/120-ad-user-created.xml) - Active Directory user creation
- [121-ad-user-deleted.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/121-ad-user-deleted.xml) - Active Directory user deletion
- [122-ad-group-modified.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/122-ad-group-modified.xml) - Active Directory group modification
- [123-ad-login-anomaly.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/windows/123-ad-login-anomaly.xml) - Active Directory login anomaly detection

### Root directory rules

- [103-scheduled-task-outofhours.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/103-scheduled-task-outofhours.xml) - Scheduled task execution outside business hours
- [104-exec-from-temp-downloads.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/104-exec-from-temp-downloads.xml) - Execution from temp or downloads folder
- [105-rdp-enabled-or-firewall-changed.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/105-rdp-enabled-or-firewall-changed.xml) - RDP enabled or firewall changed
- [107-local-auth-failures.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/107-local-auth-failures.xml) - Local authentication failures

## Test steps

1. SSH brute: from another host run 5 failed ssh attempts within 60s to the target.
2. PowerShell encoded: `powershell -EncodedCommand <base64>` on Windows agent with Sysmon enabled.
3. User creation: `net user testlab P@ssw0rd /add` (local) or create via AD in lab.
4. Check Wazuh manager `alerts` or dashboard for rule ids (100100–100106).
