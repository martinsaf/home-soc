# Active Directory Domain Controller Setup

## Purpose

Set up a Windows Server as a Domain Controller in the home lab to practice identity and access management, aligning with IT support/administration roles.

## Lab Environment

- **Server OS:** Windows Server 2022 Evaluation (Desktop Experience)
- **VM Platform:** VirtualBox
- **Host Machine:** Windows Laptop (192.168.200.2)
- **Network:** Lab subnet 192.168.200.0/24 (Ethernet bridge) + Wi+Fi for internet

## Prerequisites

- Windows Server 2022 ISO downloaded ([Windows Server 2022](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022?msockid=0c66b263bc8e6af42ae4a7e0bd416bb4))

## Step-by-Step Installation

1. **Name and OS:**
   - Name: `DC01`
   - ISO Image: Select your Windows Server 2022 ISO
   - **OS Edition:** Choose **"Windows Server 2022 Standard Evaluation (Desktop Experience)"** (this is crucial!)

2. **Hardware:**
   - RAM: 2896 MB
   - CPU: 3

3. **Hard Disk:**
   - 50 GB (dynamically allocated)

4. **Network:**
   - After VM creation, go to Settings -> Network
   - **Adapter 1:**
     - Enable
     - Attached to: Bridged Adapter
     - Name: Select your Ethernet adapter (the one with IP 192.168.200.1)
   - **Adapter 2:**
     - Enable
     - Attached to: Bridged Adapter
     - Name: Select your Wi-Fi adapter

### 2. Install Windows Server

Since you configured the ISO and OS Edition during VM creation, VirtualBox handles the installation automatically:

1. Start the VM
   - The VM will boot from the ISO automatically, the installation runs on its own
   - The VM may restart several times - **let it run**

### 3. Initial Configuration (Post-Installation)

#### 3.1 First Login

    - Log in with the administrator password you set during VM creation (if needed)

#### 3.2 Install VirtualBox Guest Additions

This enables clipboard sharing, drag & drop, and better screen resolution:

[Tutorial from channel OnlineComputerTips](https://www.youtube.com/watch?v=tXhmcfiPe9w)

1. In the VM menu: **Devices** -> **Insert Guest Additions CD image**
2. In the VM, open **File Explorer**
3. Go to the CD Drive (usually D:)
4. Right-click `VBoxWindowsAdditions.exe` and select **"Run as administrator"** or just "double-click" to run the program
5. Follow the installation wizard (accept defaults)
6. When prompted, select **"Reboot now"**

After reboot, log in again.

**Enable Clipboard Sharing:**

- In the VM menu: **Devices** -> **Sharing Clipboard** -> **Bidirectional**
- Test by copying something from your host to the VM and vice versa

#### 3.3 Configure Static IP Address

1. Right-click the **network icon** in the system tray (bottom-right)
2. Select **"Open Network & Internet settings"**
3. Click **"Change adapter options"**
4. **Identify your adapters:**
   - **Adapter 1 (lab network):** Usually "Ethernet" or "Ethernet0"
   - **Adapter 2 (internet)**: Usually "Ethernet 2" (gets IP via DHCP from your home router)
5. Right-click the **lab network adapter** (Adapter 1)
6. Select **"Properties"**
7. Double-click **"Internet Protocol Version 4 (TCP/IPv4)"**
8. Select **"Use the following IP address:"**
   - **IP address:** `192.168.200.10`
   - **Subnet mask:** `255.255.255.0` (press Tab and it fills automatically, is /24)
   - **Default gateway:** `192.168.200.1` (your laptop's IP in the lab network)
9. Select **"Use the following DNS server address:"**
   - **Preferred DNS server:** `127.0.0.1` (will be updated when AD is installed)
10. Click **OK**

#### 3.4 Enable ICMP (Ping) for Lab Connectivity

By default, Windows Firewall blocks ping requests. To allow other lab devices to reach this server:

- **Option 1:** Direct PowerShell command

```powershell
# Open PowerShell as Administrator
# Create a firewall rule to allow ICMPv4 (ping)
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow

# Verify the rule was created
Get-NetFirewallRule -DisplayName "Allow ICMPv4-In" | Format-List
```

- **Option 2:** Use the provided script

**To enable ICMP:**
[`allow-icmp-ping.ps1`](https://github.com/martinsaf/home-soc/blob/main/scripts/powershell/allow-icmp-ping.ps1)

The output of this script should be something like this:

```bash
PS C:\Users\vboxuser\Documents> .\allow-icmp-ping.ps1


Name                          : {a7641b13-e598-4b5e-96dd-b3225e1cf659}
DisplayName                   : Allow ICMPv4-In
Description                   : Allow ICMPv4 echo requests (ping) for lab connectivity
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Inbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}

Firewall rule 'Allow ICMPv4-In' created successfully.

Rule details:




Name        : {a7641b13-e598-4b5e-96dd-b3225e1cf659}
DisplayName : Allow ICMPv4-In
Enabled     : True
Direction   : Inbound
Action      : Allow
```

**To disable ICMP (restore default):**
[`disable-icmp-ping.ps1`](https://github.com/martinsaf/home-soc/blob/main/scripts/powershell/disable-icmp-ping.ps1)

The output of this script should be something like this:

```bash
PS C:\Users\vboxuser\Documents> .\disable-icmp-ping.ps1
Firewall rule 'Allow ICMPv4-In' removed successfully.
```

Or use the unified script with parameters:
[`Set-ICMPFirewallRule.ps1`](https://github.com/martinsaf/home-soc/blob/main/scripts/powershell/Set-ICMPFirewallRule.ps1)

The output of this script should be something like this for -Enable:

```bash
PS C:\Users\vboxuser\Documents> .\Set-ICMPFirewallRule.ps1 -Enable


Name                          : {fcbc0842-a88c-4b23-aaca-77ab41661ac6}
DisplayName                   : Allow ICMPv4-In
Description                   : Allow ICMPv4 echo requests (ping) for lab connectivity
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Inbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}

Firewall rule 'Allow ICMPv4-In' created successfully.

Current rule status: - ForegroundColor Cyan




Name        : {fcbc0842-a88c-4b23-aaca-77ab41661ac6}
DisplayName : Allow ICMPv4-In
Enabled     : True
Direction   : Inbound
Action      : Allow
```

The output of this script should be something like this for -Disable:

```
PS C:\Users\vboxuser\Documents> .\Set-ICMPFirewallRule.ps1 -Disable
Firewall rule 'Allow ICMPv4-In' removed successfully.
```

#### 3.5 Verify Network Configuration

```powershell
# Check IP configuration
ipconfig /all

# Test lab network connectivity
ping 192.168.200.1 # my Laptop/gateway
ping 192.168.200.2 # my Wazuh server

# Test internet connectivity (via Adapter 2)
ping 8.8.8.8
```

#### 3.6 Rename the Computer

1. Open Settings (Windows key + I)
2. Go to System -> About
3. Click "Rename this PC"
4. Change name to `DC01`
5. Click Next -> Restart now

### 4. Install Active Directory Domain Services (AD DS)
