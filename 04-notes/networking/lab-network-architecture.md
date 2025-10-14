# Lab Network Architecture

## Overview
My home SOC lab uses a dedicated physical subnet (`192.168.200.0/24`) for internal communication, isolated from my personal/home network.  
All lab traffic flows through the **Ethernet (RJ-45) interface** of my Windows laptop, which acts as the central network hub.

## Components
- **Windows Laptop (Host)**
  - Physical machine running Virtualbox/Hyper-V
  - Ethernet interface configured with static IP: `192.168.200.1/24`
  - This interface connect directly (via RJ-45 cable) to the Ubuntu Server.
  - Hosts two VMs:
    - **Windows 10 VM** (`192.168.200.20`)
    - **Ubuntu 22.04 VM** (`192.168.200.30`)

- **Ubuntu Server**
  - Physical or separate machine (not a VM on this laptop)
  - Connected directly to the laptop via Ethernet cable.
  - IP: `192.168.200.10`
  - Runs: **Wazuh Manager, Indexer, and Dashboard** (All-in_one).
 
- **Virtual Machines (on Windows Laptop)**
  - Both VMs use **two netork adapters**
    1. **Adapter 1**: *Bridged Adapter* -> **Ethernet (RJ-45)**
       -> Gets IP in `192.168.200.0/24` -> communicates with Wazuh server and other lab devices.
    2. **Adapter 2**: *Bridged Adapter* -> **Wi-Fi**
       -> Provides internet access (for updates, package installs, etc.) **not used for lab traffic**.

## Connectivity
- All devices in `192.168.200.0/24` can ping each other:
  - Laptop (`192.168.200.1`)
  - Windows VM (`192.168.200.20`)
  - Ubuntu VM (`192.168.200.30`)
  - Ubuntu Server (`192.168.200.10`)

## Why This Design?
> - The **Ethernet interface** creates a clean, isolated physical segment for SOC telemetry (Sysmon, auditd, Wazuh agent traffic).
> - **Bridging to Ethernet** (not NAT or Host-only) ensures VMs appear as real devices on the `192.168.200.0/24` network - critical for realistic agent-to-server communication.
> - The **second Wi-Fi adapter** is purely for convenience (OS updates, Git pulls), and is **disabled during offensive simulations** to avoid noise or leaks.
