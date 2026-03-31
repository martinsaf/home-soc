# Lab Knowledge Base

This directory contains structured, topic-based documentation for my home SOC lab.

Each file captures a reusable concept, configuration, or detection workflow — **a reference for future me** (and anyone else who stumbles upon this repo 🙃).

> 🔍 **Tip:** Use `Ctrl+F` or your editor's search to find topics quickly.  
> 📁 Related artifacts (rules, scripts, configs) live in `/monitoring/`, `/scripts/`, and are referenced from their respective docs.

 🚧 *Work in progress — documentation is continuously updated*

---

## 🗂️ Table of Contents

- [Active Directory](./active-directory/README.md)
- [Email](./email/)
- [ITSM](./itsm/)
- [Windows](./windows/)
- [Linux](./linux/)
- [Networking](./networking/)
- [Troubleshooting](./networking/)
- [Monitoring Rules](../monitoring/wazuh-rules/README.md)

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

## Email 📧

| Document | Description |
| - | - |
| [hMailServer-setup-on-DC01.md](./email/hMailServer-setup-on-DC01.md) | Install and configure hMailServer IMAP/SMTP on Windows Server 2022 (DC01) |
| [rainloop-setup.md](./email/rainloop-setup.md) | Deploy RainLoop webmail client via Docker on Windows laptop |

---

## ITSM 🤹

| Document | Description |
| - | - |
| [glpi-setup.md](./itsm/glpi-setup.md) | GLPI ticketing system setup via Docker (files created, implementation pending) |
| [cmdb.md](./itsm/cmdb.md) | Simple asset inventory in Markdown format |

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
| [ad-integration-linux.md](./linux/ad-integration-linux.md) | Join Ubuntu endpoint to Active Directory domain via realmd/SSSD |
| [`lab-network-architecture.md`](./networking/lab-network-architecture.md) | Network diagram, VLANs, and firewall rules for the lab |

---

## Troubleshooting 🔧

| Document | Description |
| :--- | :--- |
| [`ssh-bruteforce-attack.md`](./troubleshooting/ssh-bruteforce-attack.md) | Detect and respond to SSH brute-force attempts |
| [`wazuh-agent-disconnected.md`](./troubleshooting/wazuh-agent-disconnected.md) | Fix Wazuh agent connectivity issues |
| [`rainloop-short-login-authentication-problem.md`](./rainloop-short-login-authentication-problem.md) | RainLoop authentication failures due to short login bug with hMailServer |

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
├── active-directory/     # AD setup, users, GPOs, Wazuh integration
│   ├── imgs/
│   ├── ad-installation.md
│   ├── ad-users-groups.md
│   ├── ad-join-windows-client.md
│   ├── ad-group-policy.md
│   ├── ad-integration-wazuh.md
│   ├── ad-troubleshooting.md
│   └── README.md
├── email/                # Email server + webmail configuration
│   ├── hMailServer-setup-on-DC01.md
│   └── rainloop-setup.md
├── itsm/                 # ITSM ticketing and CMDB (files created, pending implementation)
│   ├── glpi-setup.md
│   └── cmdb.md
├── linux/                # Linux endpoint: AD join, auditd
│   ├── imgs/
│   ├── ad-integration-linux.md
│   └── auditd-config.md
├── networking/           # Network design and firewall rules
│   └── lab-network-architecture.md
├── troubleshooting/      # Incident response and common fixes
│   ├── ssh-bruteforce-attack.md
│   ├── wazuh-agent-disconnected.md
│   └── rainloop-short-login-authentication-problem.md
├── windows/              # Windows endpoint: Sysmon, hardening
│   ├── sysmon-config.md
│   ├── sysmon-validation.md
│   └── windows-endpoint.md
├── next-steps-summary.md
└── README.md             # You are here
```