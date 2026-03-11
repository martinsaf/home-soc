# Active Directory Domain Controller Setup

## Purpose

Set up a Windows Server as a Domain Controller in the home lab to practice identity and access management, aligning with IT support/administration roles.

## Lab Environment

- **Server OS:** Windows Server 2022 Evaluation (Desktop Experience)
- **VM Platform:** VirtualBox
- **Host Machine:** Windows Laptop (192.168.200.1)
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

#### 4.1 Install AD DS Role

**Using Server Manager (GUI):**

1. **Server Manager** should open automatically when you log in. If not, open it from the taskbar.
2. Click **"Add roles and features"** (or go to Dashboard -> Add roles and features)
3. Click **Next** until you reach the **"Server Roles"** section
4. Check the box for **"Active Directory Domain Service"**
   - A pop-up will appear asking to add required features
   - Click **"Add Features"**
5. Click **Next** until you reach the **"Confirmation"** page
6. Check **"Restart the destination server automatically if required"**
7. Click **"Install"**

The installation will take a few minutes. When it completes, you'll see a message saying "Configuration required. Installation succeeded on DC01."

#### 4.2 Promote the Server to Domain Controller

After the AD DS role is installed, the server needs to be promoted to a Domain Controller.

**Look for the yellow flag:**

1. In **Server Manager**, look at the top-right corner for a **yellow notification flag** 🟨
2. Click on the flag - you'll see a message: **"Post-deployment Configuration: Configuration required for Active Directory Domain Service at DC01"**
3. Click the link: **"Promote this server to a domain controller"**

**If the yellow flag doesn't appear:**

- Open **Server Manager**
- Click on **"Notifications"** (the flag icon)
- Select **"Promote this server to a domain controller"**

**Configuration steps:**

1. **Deployment Configuration:**
   - Select **"Add a new forest"**
   - **Root domain name:** `lab.local`
   - Click **Next**

2. **Domain Controller Options:**
   - **Forest functional level:** Windows Server 2016 (default is fine)
   - **Domain functional level:** Windows Server 2016
   - Check **"Domain Name System (DNS) server"** (this is important!)
   - Check **"Global Catalog (GC)"** (its checked by default)
   - **Directory Services Restore Mode (DSRM) password:** Set a strong password
     - Save this password somewhere _safe_!
   - Click **Next**

3. **DNS Options:**
   - You might see a warning about DNS delegation - **ignore it** (click Next)
     - Leave **"Create DNS delegation"** unchecked (its unchecked by default)

4. **Additional Options:**
   - The NetBIOS domain name will automatically be `LAB`
   - Click **Next**

5. **Paths:**
   - Keep the default paths (they're fine for a lab)
   - Database folder: `C:\Windows\NTDS`
   - Log files: `C:\Windows\NTDS`
   - SYSVOL: `C:\Windows\SYSVOL`
   - Click **Next**

6. **Review Options:**
   - Review your selections
   - Click **Next**

7. **Prerequisites Check:**
   - Wait for the check to complete
   - You may see warning (like "This computer has at least one physical network adapter" - thats normal)
   - All prerequisite checks should pass with green checkmars
   - Click **"Install"**

> You'll see several warnings - this is normal for a first domain controller:

```text
Windows Server 2022 domain controllers have a default for the security setting named "Allow cryptography algorithms compatible with Windows NT 4.0" that prevents weaker cryptography algorithms when establishing security channel sessions.

For more information about this setting, see Knowledge Base article 942564 (http://go.microsoft.com/fwlink/?LinkId=104751).

This computer has at least one physical network adapter that does not have static IP address(es) assigned to its IP Properties. If both IPv4 and IPv6 are enabled for a network adapter, both IPv4 and IPv6 static IP addresses should be assigned to both IPv4 and IPv6 Properties of the physical network adapter. Such static IP address(es) assignment should be done to all the physical network adapters for reliable Domain Name System (DNS) operation.

A delegation for this DNS server cannot be created because the authoritative parent zone cannot be found or it does not run Windows DNS server. If you are integrating with an existing DNS infrastructure, you should manually create a delegation to this DNS server in the parent zone to ensure reliable name resolution from outside the domain "lab.local". Otherwise, no action is required.

Prerequisites Check Completed

All prerequisite checks passed successfully.  Click 'Install' to begin installation.
```

The server will automatically restart after promotion. This may take a few minutes.

#### 4.3 Post-Installation Verification

After the reboot, log in as **`LAB\Administrator`** (or `lab.local\administrator`) using the same password you used before.

**Verify AD Services:**

```powershell
# Check if AD services are running
Get-Service *ad* | Where-Object {$_.Status -eq "Running"} | Format-Table Name, Status
```

**Verify DNS Zones:**

```powershell
# List DNS zones
Get-DnsServerZone | Format-Table ZoneName, ZoneType
```

You should see at least:

- `lab.local` (primary zone)
- `_msdcs.lab.local` (primary zone)

**Verify Domain Information:**

```powershell
# Get domain information
Get-ADDomain

# Get domain controller information
Get-ADDomainController
```

My output:

```bash
PS C:\Windows\system32> Get-Service *ad* | Where-Object {$_.Status -eq "Running"} | Format-Table Name, Status

Name  Status
----  ------
ADWS Running


PS C:\Windows\system32> Get-DnsServerZone | Format-Table ZoneName, ZoneType

ZoneName         ZoneType
--------         --------
_msdcs.lab.local Primary
0.in-addr.arpa   Primary
127.in-addr.arpa Primary
255.in-addr.arpa Primary
lab.local        Primary
```

**Test DNS Resolution:**

```powershell
# Test DNS resolution for the domain
Resolve-DnsName lab.local

# Test DNS resolution for the domain controller
Resolve-DnsName dc01.lab.local
```

My output:

```bash
PS C:\Windows\system32> Resolve-DnsName lab.local

Name                                           Type   TTL   Section    IPAddress
----                                           ----   ---   -------    ---------
lab.local                                      A      600   Answer     192.168.0.111
lab.local                                      A      600   Answer     192.168.200.10


PS C:\Windows\system32> Resolve-DnsName dc01.lab.local

Name                                           Type   TTL   Section    IPAddress
----                                           ----   ---   -------    ---------
DC01.lab.local                                 AAAA   1200  Question   fe80::f429:8ec2:f3fb:503d
DC01.lab.local                                 A      1200  Question   192.168.0.111
DC01.lab.local                                 A      1200  Question   192.168.200.10
```

#### 4.4 Access AD Management Tools

1. In **Server Manager**, go to the Tools menu (top-right corner)
2. You should see:
   - **Active Directory Users and Computers** (most important for now)
   - Active Directory Domains and Trusts
   - Active Directory Sites and Service
   - DNS
   - Group Policy Management

**Quick test:** Open **Active Directory Users and Computers** and verify that:

- Your domain `lab.local` appears
- Default containers exist (Builtin, Computers, Domain Controllers, Users)

#### 4.5 Verification Checklist

- AD DS role installed successfully
- Server promoted to Domain Controller (via yellow flag)
- DNS zones created (\_msdcs.lab.local, lab.local)
- Can log in with domain admin (LAB\Administrator)
- AD management tools available
- DNS resolution working for lab.local
- Active Directory Users and Computers shows default containers
