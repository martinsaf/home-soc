# Next Steps Summary: Lab Expansion

## Purpose
This document tracks completed work and outlines future phases for expanding the home SOC lab. Focus areas align with real-world Service Desk / SOC Analyst skills: log enrichment, vulnerability management, automation, and threat detection.

## Next

### ITSM / CMDB (GLPI)
- Status: Not Completed
- Components:
  - GLPI ticketing system via Docker
  - Basic CMDB asset inventory in Markdown
- Documentation:
  - [glpi-setup.md](../itsm/glpi-setup.md)
  - [cmdb.md](../itsm/cmdb.md)
- Notes:
  - Files created but not yet implemented
  - Awaiting Docker deployment and initial configuration

## Completed Work

### Email Management (hMailServer + RainLoop)
- Status: Completed
- Components:
  - hMailServer IMAP/SMTP on Windows Server 2022 (DC01)
  - RainLoop webmail via Docker on Windows laptop
  - Authentication via local hMailServer accounts (AD integration optional)
- Documentation:
  - [hMailServer-setup-on-DC01.md](../email/hMailServer-setup-on-DC01.md)
  - [rainloop-setup.md](../email/rainloop-setup.md)
  - [rainloop-short-login-authentication-problem.md](../troubleshooting/rainloop-short-login-authentication-problem.md)
- Verification:
  - Users can send/receive email via RainLoop at http://192.168.200.1:8080
  - Authentication requires full email address (carlos.silva@lab.local)

### Linux AD Integration
- Status: Completed
- Components:
  - Ubuntu endpoint joined to lab.local via realmd/SSSD
  - Domain user authentication via SSH
- Documentation:
  - [ad-integration-linux.md](../linux/ad-integration-linux.md)

### Active Directory Integration
- Status: Completed
- Components:
  - Windows Server 2022 as Domain Controller (lab.local)
  - Windows 10 endpoint joined to domain
  - Group Policy Objects for security baseline
  - Wazuh agent installed on DC01 with custom rules
- Documentation:
  - [ad-installation.md](../active-directory/ad-installation.md)
  - [ad-join-windows-client.md](../active-directory/ad-join-windows-client.md)
  - [ad-integration-wazuh.md](../active-directory/ad-integration-wazuh.md)

---

## Repository Structure Reference
```text
docs/
├── email/
│   ├── hMailServer-setup-on-DC01.md
│   └── rainloop-setup.md
├── itsm/
│   ├── glpi-setup.md
│   └── cmdb.md
├── linux/
│   └── ad-integration-linux.md
├── troubleshooting/
│   ├── ssh-bruteforce-attack.md
│   ├── wazuh-agent-disconnected.md
│   └── rainloop-short-login-authentication-problem.md
├── windows/
│   ├── sysmon-config.md
│   ├── sysmon-validation.md
│   └── windows-endpoint.md
├── active-directory/
├── networking/
├── monitoring/
├── next-steps-summary.md
└── README.md
```