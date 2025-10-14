# Lab Network Architecture

## Overview
My home SOC lab consists of three core systems connected over physical subnit (`192.168.200.0/24`), isolated from my personal/home network for safety and clarity.

+------------------+ +---------------------+
| | | |
| Windows Laptop |<----->| Ubuntu Server |
| (Host Machine) | RJ-45 | (Wazuh All-in-One) |
| | | 192.168.200.10 |
+------------------+ +---------------------+
↑
| VirtualBox / Hyper-V
↓
+------------------+
| |
| Windows 10 VM |
| 192.168.200.20 |
+------------------+
↑
| VirtualBox / Hyper-V
↓
+------------------+
| |
| Ubuntu 22.04 VM |
| 192.168.200.30 |
+------------------+
