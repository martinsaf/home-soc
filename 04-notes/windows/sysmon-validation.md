# Sysmon Validation

## Purpose
Confirm that Sysmon is generating expected events and that Wazuh is receiving them.

## Test Procedure

### 1. File creation in `C:\temp` (low-value path)
```powershell
New-Item -Path C:\temp\sysmon_test.txt
```

#### No Event ID 11 generated
> Expected: `C:\temp` is excluded in `sysmon-modular` config to reduce noise.

### 2. File creation in `C:\Windows` (high-value path)
```powershell
New-Item -Path C:\Windows\wazuh_test_sysmon.txt -Value "test"
```

#### Event ID 11 generated successfully
> Confirmed via:
```poweshell
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5 | Where-Object {$_.Id -eq 11}
```

## Wazuh Integration
- Sysmon events are being forwarded to Wazuh (confirmed by presence of other high-fidelity alerts in dashboard, e.g., service creation, taskschd.dll loads).
- No custom rule needed for FileCreate - existing Wazuh rules already process relevant Sysmon events.

## Conclusion
- Sysmon is active, properly confirured (using Olaf Hartong's sysmon-modular), and integrated with Wazuh.
- Telemetry pipeline is operational for detection engineering.
