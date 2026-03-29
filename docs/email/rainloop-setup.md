# RainLoop Webmail with Docker

## Objective
Deploy a lightweight webmail client using Docker on Windows, accessible from the lab network and localhost

## Prerequisites
- Docker Desktop for Windows installed and running
- Windows laptop with IP `192.168.200.1` on the lab Ehternet network
- Port `8080` available on the host

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

Create `docker-compose.yml`:
```yaml
services:
  rainloop:
    image: neolao/rainloop
    container_name: rainloop
    restart: always
    ports:
      - "8080:8888"
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
```powershell
CONTAINER ID   IMAGE               COMMAND    CREATED          STATUS          PORTS                                         NAMES
133270f5374f   hardware/rainloop   "run.sh"   28 minutes ago   Up 28 minutes   0.0.0.0:8080->8888/tcp, [::]:8080->8888/tcp   rainloop
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

### Update Admin Password

In the **Admin Panel Access Credential** section:

| Field | Value |
| - | - |
| Current password | `12345` |
| New login | `admin` *(keep)* |
| New password | *(choose a strong password)* |
| Repeat | *(confirm)* |

Click **Update Password**

### Security Setting

Recommended configuration for lab environment:

| Setting | Value | Reason |
| - | - | - |
| Allow 2-Step Verification | Unchecked | Not needed in lab |
| Enforce 2-Step Verification | Unchecked |  |
| Use local proxy for external images | Checked | Privacy and security |
| Allow OpenPGP | Unchecked | Only if encryption is needed |
| Show PHP information | Unchecked | Avoid exposing system info |

### SSL Settings

| Setting | Value | Reason |
| - | - | - |
| Require Verification of SSL certificate | Unchecked | Lab may use self-signed certs |
| Allow self signed certificates | Checked | Required for testing with DC or custom mail servers |

---

### Add a Domain

To test with Active Directory domain