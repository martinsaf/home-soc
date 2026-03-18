# Lab Knowledge Base

This directory contains structured, topic-based documentation for my home SOC lab.

Each file captures a reusable concept, configuration, or detection workflow — **a reference for future me** (and anyone else who stumbles upon this repo 🙃).

> 🔍 **Tip:** Use `Ctrl+F` or your editor's search to find topics quickly.  
> 📁 Related artifacts (rules, scripts, configs) live in `/monitoring/`, `/scripts/`, and are referenced from their respective docs.

 🚧 *Work in progress — documentation is continuously updated*

---

## 🗂️ Table of Contents

- [Active Directory](#active-directory)
- [Windows](#windows)
- [Linux](#linux)
- [Networking](#networking)
- [Troubleshooting](#troubleshooting)
- [Monitoring Rules](#monitoring-rules)

---

## Active Directory 🔐

| Document | Description |
| :--- | :--- |
| [`ad-installation.md`](./active-directory/ad-installation.md) | Install and configure a Domain Controller (`DC01`) |
| [`ad-users-groups.md`](./active-directory/ad-users-groups.md) | Create OUs, users, and groups with PowerShell/GUI |
| [`ad-join-windows-client.md`](./active-directory/ad-join-windows-client.md) | Join Windows 10 client to the domain |
| [`ad-group-policy.md`](./active-directory/ad-group-policy.md) | Deploy GPOs: wallpaper, drive maps, restrictions |
| [`ad-integration-wazuh.md`](./active-directory/ad-integration-wazuh.md) | Forward AD events to Wazuh for monitoring |
| [`ad-troubleshooting.md`](./active-directory/ad-troubleshooting.md) | Common AD issues and solutions |

> 🖼️ Screenshots: [`./active-directory/imgs/`](./active-directory/imgs/)

---

## Windows 🪟

| Document | Description |
| :--- | :--- |
| [`sysmon-config.md`](./windows/sysmon-config.md) | Modular Sysmon configuration (Olaf Hartong) |
| [`sysmon-validation.md`](./windows/sysmon-validation.md) | Test and validate Sysmon event collection |
| [`windows-endpoint.md`](./windows/windows-endpoint.md) | General Windows endpoint hardening notes |

**External Resources:**
- [Sysmon Modular Config](https://github.com/olafhartong/sysmon-modular)

---

## Linux 🐧

| Document | Description |
| :--- | :--- |
| [`auditd-config.md`](./linux/auditd-config.md) | Monitor `sudo`, identity changes, and SSH config with `auditd` |

---

## Networking 🌐

| Document | Description |
| :--- | :--- |
| [`lab-network-architecture.md`](./networking/lab-network-architecture.md) | Network diagram, VLANs, and firewall rules for the lab |

---

## Troubleshooting 🔧

| Document | Description |
| :--- | :--- |
| [`ssh-bruteforce-attack.md`](./troubleshooting/ssh-bruteforce-attack.md) | Detect and respond to SSH brute-force attempts |
| [`wazuh-agent-disconnected.md`](./troubleshooting/wazuh-agent-disconnected.md) | Fix Wazuh agent connectivity issues |

---

## Monitoring Rules 🚨

Custom Wazuh rules for detection:

📁 [`/monitoring/wazuh-rules/`](../monitoring/wazuh-rules/)

| Category | Rules |
| :--- | :--- |
| **Windows** | PowerShell encoding, bruteforce, AD user changes, temp file execution |
| **Linux** | SSH bruteforce, sudo abuse, suspicious `/tmp` writes |
| **Generic** | Scheduled tasks out-of-hours, RDP/firewall changes, local auth failures |

> 📄 See [`README.md`](../monitoring/wazuh-rules/README.md) for rule syntax and testing.

---

## 🗃️ Project Structure Overview

```text
docs/
├── active-directory/ # AD setup, users, GPOs, Wazuh integration
├── linux/ # auditd, hardening
├── networking/ # network design, firewall rules
├── troubleshooting/ # incident response notes
├── windows/ # Sysmon, endpoint config
└── README.md # You are here 👈
```