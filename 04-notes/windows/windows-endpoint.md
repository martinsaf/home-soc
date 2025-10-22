# Windows Endpoint Configuration (Sysmon + Wazuh Agent)

## Purpose
Provide a lightweight reference for the Windows VM's security telemetry stack in the home SOC lab.

## Componentes Instaled
- **Sysmon64** (v15+) - service name: `Sysmon64`
- **Wazuh Agent** - service name: `WazuhSvc`
- Windows Event Logs enabled:
  - `Security`
  - `System`
  - `Microsoft-Windows-Sysmon/Operational`
 
## Status
- Sysmon is active and generating events (e.g., Event ID 11: FileCreate)
- Wazuh agent is running and forwarding logs to the Wazuh server
- Events visible in Wazuh Dashboard -> integration confirmed

## Verification Steps
```powershell
Get-Service Sysmon64, WazuhSvc
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
```


> For details on Sysmon rules and configuration, see:
> [Sysmon: modular configuration from Olaf Hartong](https://github.com/olafhartong/sysmon-modular)
