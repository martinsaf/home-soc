# RainLoop Webmail with Docker

## Objective
Deploy a lightweight webmail client using Docker on Windows, accessible from the lab network and localhost

## Prerequisites
- Docker Desktop for Windows installed and running
- Windows laptop with IP `192.168.200.1` on the lab Ethernet network
- Port `8080` available on the host

---

## Docker Quick Commands
```powershell
cd D:\docker-containers\rainloop
# Remove the old container if it exists
docker-compose down
# Create the docker-compose.yml file with one of the options above
notepad docker-compose.yml
# Under the container
docker-compose up -d
# Check logs
docker logs rain
```

---

## Step-by-Step Installation

### 1. Create Project Directory

```powershell
cd D:\docker-containers
mkdir rainloop
cd rainloop
```

> rainloop is in my external driver

### 2. Create Docker Compose File

Create `docker-compose.yml`. Use the working image `ghcr.io/xrstf/rainloop:v1.17.0`:

Create `docker-compose.yml`:
```yaml
services:
  rainloop:
    image: ghcr.io/xrstf/rainloop:v1.17.0
    container_name: rainloop
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./data:/var/www/html/data
``` 

### 3. Start the Container

```powershell
docker-compose up -d
```

Verify the container is running:
```powershell
docker ps
```

Expected output:
```text
CONTAINER ID   IMAGE                            COMMAND            CREATED       STATUS             PORTS                                     NAMES
26639ae06baf   ghcr.io/xrstf/rainloop:v1.17.0   "/entrypoint.sh"   2 hours ago   Up About an hour   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   rainloop
``` 

### 4. Verify Access

```powershell
curl http://localhost:8080
``` 

Should return HTML content.

---

## Access URLs

| Access Point | URL | Notes |
| - | - | - |
| Local (laptop only) | `http://localhost:8080` | Webmail interface |
| Lab network | `http://192.168.200.1:8080` | Access from VMs or Wazuh server |
| Admin panel | `http://192.168.200.1:8080/?admin` | Administration interface |

---

## Initial Configuration

### Admin Login

1. Navigate to `http://192.168.200.1:8080/?admin`
2. Default credentials:
    - **Login**: `admin`
    - **Password**: `12345`

---

### Add a Domain

> **Import:** Due to a bug/incompatibility in this RainLoop image, **short login must be disabled**. Users will have to log in with their full email address (`user@lab.local`)

To test with Active Directory domain:

1. In admin panel, go to **Domains -> Add Domain**
  - *Uncheck* gmail.com
2. Fill in:
  - Name (wildcard supported): `lab.local`
  - IMAP Settings:
    - Server: `192.168.200.10`
    - Port: `143`
    - Secure: `None` 
    - Use short login: ❌ *Unchecked* (critical)
  - SMTP Settings:
    - Server: `192.168.200.10`
    - Port: `587`
    - Secure: `None` 
    - Use short login: ❌ *Unchecked* (critical)
    - Use authentication: *Checked*
    - Use php mail() function: *Unchecked*
3. Click **Save**

#### Test Login

Navigate to the webmail URL (`http://192.168.200.1:8080`) and log in with:"
  - **Email:** `carlos.silva@lab.local` (full email, as short login is disabled)
  - **Password:** the user's AD password (or the password set in hMailServer)

> **Note**: A functional mail server (IMAP/SMTP) with authentication enabled is required for login to succeed.

---

# Troubleshooting

See the dedicated troubleshooting document: [rainloop-short-login-authentication-problem.md](../troubleshooting/rainloop-short-login-authentication-problem.md)

Common issues and solutions:

| **Issue** | **Solution** |
| - | - |
| `Domain is not allowed` | Ensure the domain is correctly added and active. Disable short login. |
| `Authentication failed` | Use full email address. Check hMailServer logs. |
| `Can't connect to server` | Verify hMailServer IP ranges and firewall rules. | 
| Black page after login | Clear browser cache or try different browser. | 

---

# Lessons Learned

- The RainLoop image `ghcr.io/xrstf/rainloop:v1.17.0` does not handle `short_login` correctly. Disabling it is the easiest fix.
- Always verify network connectivity from the container to the mail server (`docker exec rainloop ping 192.168.200.10`)
- hMailServer requires explicit IP range configuration to allow external connections.