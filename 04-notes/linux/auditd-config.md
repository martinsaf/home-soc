# auditd Configuration for SOC Lab

## Purpose
Monitor privilege escalation, identity changes, and critical file access on the Ubuntu endpoint for Wazuh-based detection
- Privilege escalation (`sudo` usage)
- Identify changes (`/etc/passwd`, `/etc/group`, `/etc/shadow`)
- SSH configuration tampering
- Root command execution

All events are tagged with `-k` (key) for Wazuh correlation.

## Current Rules (`sudo auditctl -l`)
- `a always,exit -F arch=b64 -S execve -F euid=0 -F key=audit-wazuh-c`
- `a always,exit -F arch=b32 -S execve -F euid=0 -F key=audit-wazuh-c`
- `a always,exit -F arch=b64 -S execve -F key=exec`
- `a always,exit -F arch=b32 -S execve -F key=exec`
- `-w /etc/passwd -p wa -k identity`
- `-w /etc/shadow -p wa -k identity`
- `w /etc/group -p wa -k identity`
- `w /usr/bin/sudo -p x -k priv_esc`
- `w /etc/sudoers -p wa -k config`
- `w /etc/ssh/sshd_config -p wa -k ssh_config`

## Integration with Wazuh
- Wazuh agent read logs from `/var/log/audit/audit.log`
- Events with key `audit-wazuh-c` are processed by Wazuh auditd decoder
- Confirmed working: events apper in Wazuh dasboard


## Verification Steps
- Service status: `systemctl status auditd`
- Active rules: `sudo auditctl -l`
- Log sample: `sudo tail /var/log/audit/audit.log`
