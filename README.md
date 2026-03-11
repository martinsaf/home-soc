# Home Lab - Infrastructure & Security Monitoring

This repository documents my home laboratory environment for hands-on practice with IT systems, moniroting, and security detections.

## Purpose

A sandbox to learn and experiment with:

- **Windows & Linux administration** (Active Directory, auditd, system hardening)
- **Network configuration & troubleshooting** (VLANs, routing, dual-homed servers)
- **Automation** (PowerShell, Bash, Python)
- **Monitoring & SIEM** (Wazuh, custom detection rules)
- **Security telemetry** (Sysmon, auditd, Windows Event Logs)
- **Attack simulations & detection engineering** (SSH brute-force, credential dumping, persistence)

The lab evolves as I explore new topics - from basic IT tasks to security use cases.

## 📁 Repository Structure

### 📄 Documentation (`docs/`)

| Category             | Topics                                                                                  | Link                                                                                           |
| -------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| **Active Directory** | Domain Controller setup, user/group management, integration with Wazuh, troubleshooting | [`docs/active-directory/`](./docs/active-directory/)                                           |
| **Linux**            | auditd configuration for security monitoring                                            | [`docs/linux/auditd-config.md`](./docs/linux/auditd-config.md)                                 |
| **Networking**       | Lab network architecture, IP planning, dual-homed servers                               | [`docs/networking/lab-network-architecture.md`](./docs/networking/lab-network-architecture.md) |
| **Windows**          | Sysmon configuration, validation, endpoint setup                                        | [`docs/windows/`](./docs/windows/)                                                             |
| **Troubleshooting**  | Issues solved in the lab (agent disconnected, SSH attacks)                              | [`docs/troubleshooting/`](./docs/troubleshooting/)                                             |

### 🛠️ Scripts (`scripts/`)

Automation and utility scripts for lab management:

| Language       | Purpose                                             | Link                                           |
| -------------- | --------------------------------------------------- | ---------------------------------------------- |
| **PowerShell** | Firewall rules (ICMP enable/disable), AD automation | [`scripts/powershell/`](./scripts/powershell/) |
| **Python**     | Attack simulations (SSH brute-force)                | [`scripts/python/`](./scripts/python/)         |

### 📊 Monitoring (`monitoring/`)

Wazuh configurations and custom detection rules:

| Category          | Rule Examples                                                                     | Link                                                                   |
| ----------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| **Linux Rules**   | SSH brute-force, sudo execution, /tmp file writes                                 | [`monitoring/wazuh-rules/linux/`](./monitoring/wazuh-rules/linux/)     |
| **Windows Rules** | PowerShell encoded commands, user creation/deletion, scheduled tasks, RDP changes | [`monitoring/wazuh-rules/windows/`](./monitoring/wazuh-rules/windows/) |

### 📋 Templates (`templates/`)

Reusable templates for documentation and knowledge base articles.

---

## ✨ Highlights

### 🔐 Security Monitoring Stack

- **SIEM:** Wazuh (manager, indexer, dashboard) all-in-one
- **Windows Telemetry:** Sysmon (modular config) + Windows Event Logs
- **Linux Telemetry:** auditd (sudo, identity changes, file access)

### 🌐 Network Architecture

- **Isolated lab subnet:** `192.168.200.0/24` (physical Ethernet segment)
- **Dual-homed servers:** Lab traffic over Ethernet, internet access via Wi-Fi
- **Bridged networking:** Realistic agent-to-server communication

## 🎯 Detection Scenarios

| Technique                                           | MITRE ATT&CK                                                | Rules                                                                                                         |
| --------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| SSH Brute-Force                                     | [T1110.001](https://attack.mitre.org/techniques/T1110/001/) | [`100-ssh-bruteforce.xml`](./monitoring/wazuh-rules/linux/100-ssh-bruteforce.xml)                             |
| PowerShell Encoded Commands                         | [T1059.001](https://attack.mitre.org/techniques/T1059/001/) | [`101-powershell-encoded.xml`](./monitoring/wazuh-rules/windows/101-powershell-encoded.xml)                   |
| User Account Creation                               | [T1136.001](https://attack.mitre.org/techniques/T1136/001/) | [`103-new-user-created.xml`](./monitoring/wazuh-rules/windows/103-new-user-created.xml)                       |
| Scheduled Task Creation                             | [T1053](https://attack.mitre.org/techniques/T1053/)         | [`103-scheduled-task-outofhours.xml`](./monitoring/wazuh-rules/103-scheduled-task-outofhours.xml)             |
| Execution from Temp/Downloads                       | -                                                           | [`104-exec-from-temp-downloads.xml`](./monitoring/wazuh-rules/104-exec-from-temp-downloads.xml)               |
| RDP/ Firewall Changes                               | [T1021](https://attack.mitre.org/techniques/T1021/)         | [`105-rdp-enabled-or-firewall-changed.xml`](./monitoring/wazuh-rules/105-rdp-enabled-or-firewall-changed.xml) |
| **Active Directory Monitoring** _To be implemented_ |                                                             |                                                                                                               |
| - User Created                                      | [T1136.001](https://attack.mitre.org/techniques/T1136/001/) | [`120-ad-user-created.xml`](./monitoring/wazuh-rules/windows/120-ad-user-created.xml)                         |
| - User Deleted                                      | [T1531](https://attack.mitre.org/techniques/T1531/)         | [`121-ad-user-deleted.xml`](./monitoring/wazuh-rules/windows/121-ad-user-deleted.xml)                         |
| - Group Modified                                    | [T1098](https://attack.mitre.org/techniques/T1098/)         | [`122-ad-group-modified.xml`](./monitoring/wazuh-rules/windows/122-ad-group-modified.xml)                     |

### 📝 Featured Documentation

- **Active Directory Setup:** Complete guide from VM creation to domain controller promotion → [`ad-installation.md`](./docs/active-directory/ad-installation.md)
- **SSH Brute-Force Simulation:** Attack simulation + detection walkthrough → [`ssh-bruteforce-attack.md`](./docs/troubleshooting/ssh-bruteforce-attack.md)
- **Wazuh Agent Troubleshooting:** Real issue resolution → [`wazuh-agent-disconnected.md`](./docs/troubleshooting/wazuh-agent-disconnected.md)

## Skills demonstrated

| Area                       | Skills                                                                  |
| -------------------------- | ----------------------------------------------------------------------- |
| **System Administration**  | Windows Server, Active Directory, Linux (Ubuntu), auditd, Sysmon        |
| **Networking**             | TCP/IP, subnetting, routing, bridging, DNS, DHCP                        |
| **Security**               | SIEM (Wazuh), detection engineering, MITRE ATT&CK mapping, log analysis |
| **Scripting & Automation** | PowerShell, Bash, Python                                                |
| **Documentation**          | Technical writing, troubleshooting guides, knowledge base articles      |

---

## 🚀 Work in Progress

This lab is continuously evolving. Recent additions:

- ✅ Active Directory Domain Controller setup
- ✅ AD monitoring rules (user/group changes)
- ✅ PowerShell scripts for firewall management

**Upcoming:**

- [ ] Join Windows 10 client to domain
- [ ] Group Policy experiments
- [ ] Azure AD Connect simulation
- [ ] Advanced attack scenarios (Kerberoasting, Golden Ticket)
