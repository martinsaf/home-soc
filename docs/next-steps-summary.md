# Next Steps Summary: Lab Expansion 🚀

## Purpose

This document outlines the next phases for expanding your home SOC lab. These steps address real-world skills mentioned in Service Desk / SOC job descriptions: **Linux AD integration**, **email management**, and **ITSM/CMDB**.

---

## 1. Integrate Linux into Active Directory 🔐

**Goal:** Authenticate domain users (`lab.local`) on Ubuntu endpoint.

### Tools Required

| Package | Purpose |
| :--- | :--- |
| `realmd` | Simplifies domain join operations |
| `sssd` | System Security Services Daemon (authentication cache) |
| `adcli` | Command-line tool for AD operations |
| `krb5-user` | Kerberos authentication support |

### Step 1.1: Configure DNS on Ubuntu

Edit `/etc/resolv.conf` or configure via Netplan:

```yaml
# /etc/netplan/01-netcfg.yaml (example)
network:
  version: 2
  ethernets:
    eth0:
      nameservers:
        addresses: [192.168.200.10]
        search: [lab.local]
```

Apply and test:
```bash
sudo netplan apply
nslookup lab.local
nslookup dc01.lab.local
```

### Step 1.2: Install Required Packages

```bash
sudo apt update
sudo apt install realmd sssd sssd-tools adcli krb5-user -y
```

### Step 1.3: Join the Domain

```bash
sudo realm join -U Administrator lab.local
```

> Enter the domain admin password when prompted.

### Step 1.4: Verify Domain Join

```bash
# List domain details
sudo realm list

# Check if AD users are visible
getent passwd carlos.silva
```

### Step 1.5: Test Login

```bash
# Via SSH (from another machine)
ssh carlos.silva@192.168.200.3

# Or locally (if GUI/console available)
# Use: LAB\carlos.silva or carlos.silva@lab.local
```

### Step 1.6: Configure Home Directories (Optional)

Auto-create home folders on first login:

```bash
# Install pam-auth-update if not present
sudo apt install libpam-sss -y

# Enable automatic home directory creation
sudo pam-auth-update
# → Enable "Create home directory on login"
```

### Troubleshooting

| Issue | Solution |
| :--- | :--- |
| `realm join` fails with "DNS resolution" | Verify `/etc/resolv.conf` points to DC |
| User not found after join | Run `sudo systemctl restart sssd` |
| Permission denied on SSH | Check `/etc/ssh/sshd_config`: `PasswordAuthentication yes` |

### Documentation

Save your notes to: `docs/linux/ad-integration-linux.md`

---

## 2. Email Management with Open-Source Server 📧

**Goal:** Simulate Exchange/Office 365 functionality: mailboxes, distribution lists, permissions.

### Option A: Mailcow (Full-Featured, Docker-Based)

> ⚠️ **Resource Warning:** Mailcow requires ~2GB RAM, 20GB disk. May be tight on Ubuntu VM.

#### Step 2.1: Install Docker on Ubuntu

```bash
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Log out and back in for group change to apply
```

#### Step 2.2: Deploy Mailcow

```bash
# Clone and configure
git clone https://github.com/mailcow/mailcow-dockerized
cd mailcow-dockerized
./generate_config.sh

# Start services
docker-compose up -d
```

#### Step 2.3: Access & Configure

- URL: `https://<ubuntu-vm-ip>` (accept self-signed cert)
- Default admin: `admin` / `moohoo`

**Create test mailboxes:**
- `carlos.silva@lab.local`
- `maria.santos@lab.local`

**Create distribution list:**
- `it-team@lab.local` → members: Carlos, Maria

#### Option B: Run Mailcow on Windows Laptop (Docker Desktop)

If Ubuntu VM resources are limited:

1. Run the same commands above in PowerShell
2. Access via `http://localhost` or your laptop's lab IP (`192.168.200.1`)

### Documentation

Save your notes to: `docs/email/mailcow-setup.md`

---

## 3. ITSM / CMDB with GLPI 🎫

**Goal:** Implement ticketing (ITSM) and asset inventory (CMDB) — common Service Desk requirements.

### 3.1 GLPI Setup (Ticketing System)

#### Option A: Docker Deployment (Recommended)

Create `docker-compose.yml`:

```yaml
version: '3'
services:
  db:
    image: mariadb:10.6
    environment:
      MYSQL_ROOT_PASSWORD: glpi_root_pass
      MYSQL_DATABASE: glpi
      MYSQL_USER: glpi_user
      MYSQL_PASSWORD: glpi_user_pass
    volumes:
      - glpi-db:/var/lib/mysql
    restart: always

  glpi:
    image: diouxx/glpi:latest
    ports:
      - "8080:80"
    environment:
      - GLPI_DB_HOST=db
      - GLPI_DB_USER=glpi_user
      - GLPI_DB_PASSWORD=glpi_user_pass
    volumes:
      - glpi-files:/var/www/html/files
    depends_on:
      - db
    restart: always

volumes:
  glpi-db:
  glpi-files:
```

Deploy:
```bash
docker-compose up -d
```

Access: `http://<ubuntu-vm-ip>:8080`

#### Step 3.2: Create Sample Tickets

Simulate real Service Desk workflows:

| Ticket | Description | Category |
| :--- | :--- | :--- |
| #001 | Create user `carlos.silva` in AD | User Management |
| #002 | Apply wallpaper GPO to IT OU | Group Policy |
| #003 | Map Z: drive for Sales team | File Sharing |
| #004 | Investigate failed login for `maria.santos` | Security |

**Workflow to practice:**
1. Open ticket → 2. Assign to technician → 3. Add notes/solution → 4. Close ticket

### 3.2 CMDB: Simple Asset Inventory (Markdown)

Create `docs/itsm/cmdb.md`:

# CMDB - Asset Inventory

| Asset | IP | OS | RAM | Disk | Role | Last Updated |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| DC01 | 192.168.200.10 | Windows Server 2022 | 3 GB | 50 GB | Domain Controller | 2026-03-20 |
| WIN10 | 192.168.200.20 | Windows 10 Enterprise | 4 GB | 60 GB | Endpoint | 2026-03-20 |
| Ubuntu-VM | 192.168.200.3 | Ubuntu 22.04 LTS | 2 GB | 30 GB | Linux Endpoint / Apps | 2026-03-20 |
| Wazuh-Server | 192.168.200.2 | Ubuntu 22.04 LTS | 4 GB | 80 GB | SIEM | 2026-03-20 |
| Mailcow | TBD | Ubuntu/Windows | - | - | Email Server | - |
| GLPI | TBD | Ubuntu/Windows | - | - | ITSM | - |

> Need to update this file whenever I add/remove lab resources.

### Documentation

Save notes to:
- `docs/itsm/glpi-setup.md`
- `docs/itsm/cmdb.md`

---

## Repository Structure Update

```
docs/
├── linux/
│   ├── ad-integration-linux.md    ← New
│   └── auditd-config.md
├── email/
│   └── mailcow-setup.md           ← New
├── itsm/
│   ├── glpi-setup.md              ← New
│   └── cmdb.md                    ← New
├── windows/
├── active-directory/
├── troubleshooting/
├── next-steps-summary.md          ← This file
└── README.md
```

---

## Success Criteria ✅

| Goal | How to Verify |
| :--- | :--- |
| Linux AD Join | `getent passwd carlos.silva` returns user info |
| Email Server | Can send/receive between `carlos@lab.local` and `maria@lab.local` |
| GLPI Tickets | Can create, assign, and close a ticket with audit trail |
| CMDB | Asset table reflects current lab state |
