# Windows Endpoint Configuration (Sysmon + Wazuh Agent)

## Purpose
Capture endpoint telemetry (process, file, network activity) via Sysmon and forward to Wazuh for detection.

## Componentes Instaled
- **Sysmon64** (v15+) - service name: `Sysmon64`
- **Wazuh Agent** - service name: `WazuhSvc`
- Windows Event Logs enabled:
  - `Security`
  - `System`
  - `Microsoft-Windows-Sysmon/Operational`
 
## Current Sysmon Behavior (Observed)
Based on live event (`Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational"`):
- **Event ID 11 (FileCreate)** is being logged -> file creation monitoring is active

## Wazuh Integration
- Wazuh agent reads:
  - `Microsoft-Windows-Sysmon/Operational`
  - Windows Security log (logon, account changes)
- Event appear in Wazuh Dashboard under **Windows** -> confirmed working.

## Verification Steps
```powershell
# Get Sysmon service
Get-Service Sysmon64

# View recent Sysmon events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5

# Check Wazuh agent
Get-Service WazuhSvc

