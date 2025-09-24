# local_rules

Custom Wazuh rules for the Home SOC lab.

## How to use
- Each XML file is a single rule or rule group. IDs use range 100100-100199.
- Deploy to `/var/ossec/etc/rules/` and restart `wazuh-manager`

## Rules included
- `100-ssh-bruteforce.xml` - SSH brute force (T1110.001)
- `101-powershell-encoded.xml` - PowerShell EncodedCommand (T1059.001)
- `102-new-user-created.xml` - User creation (EventID 4720) (T1078)
- `103-scheduled-task-outofhours.xml` - Scheduled task creation (EventID 4698) (T1053)
- `104-exec-from-temp-downloads.xml` - Execution from temp / Downloads
- `105-rdp-enabled-or-firewall-changed.xml` - RDP / firewall changes
- `106-curl-wget-to-ip.xml` - direct curl/wget to IP (egress)

## Test steps (example)
1. SSH brute: from another host run 5 failed ssh attempts within 60s to the target.  
2. PowerShell encoded: `powershell -EncodedCommand <base64>` on Windows agent with Sysmon enabled.  
3. User creation: `net user testlab P@ssw0rd /add` (local) or create via AD in lab.  
4. Check Wazuh manager `alerts` or dashboard for rule ids (100100–100106).  
