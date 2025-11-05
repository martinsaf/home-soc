# Sysmon Configuration

## Source
- **Repository**: [olafhartong/sysmon-modular](https://github.com/olafhartong/sysmon-modular)
- **Version**: 4.90
- **Local path in lab**: `C:\Sysmon\sysmonconfig.xml`

> This configuration is widely used in security labs and detection engineering due to its modularity, ATT&CK alignment, and balance between coverage and noise.

## Purpose
Enable comprehensive enpoint visibility for Wazuh-based detection of:
- Process creation and command-line logging (Event ID 1)
- Network connections (Event ID 3)
- File creation and writes (Event ID 11)
- Reistry modifications (Event ID 12-14)
- PowerShell, WMI, .NET, and suspicious execution patterns
- Lateral movement and persistence techniques

The modular design allows selective rule inclusion (e.g., enable `powershell` rules but disable `browser` if not needed)

## Key Features
- Rules grouped by threat behavior (e.g., `credential_access`, `execution`, `persistence`)
- Exclusions for common noise (e.g., `C:\Windows\Temp`, antivirus paths)
- Full command-;ine capture processes
- DNS query logging (if enabled)
- MITRE ATT&CK technique references in comments

## Local Modifications
- **Removed exclusion for `cipher.exe`**in `1_process_creation` rules to enable detection of its execution
  - Original line removed:
    ```xml
    <Image condition="contains">cipher.exe</Image>
    ```
  - Reason: Support custom Wazuh rule (`108100`) to alert on suspicious use of `cipher /w`.

## Intregation with Wazuh
- Wazuh agent reads: `Microsoft-Windows-Sysmon/Operational`
- Events appear in Wazuh Dashboard with full context (process, parent, command line, hashes)
- Confirmed working: Event ID 11 (FileCreate) and others visible in logs

## Verification
```powershell
# Check Sysmon service
Get-Service Sysmon64

# View recent events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
```

