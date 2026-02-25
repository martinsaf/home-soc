# Troubleshooting: Wazuh agent disconnected (cause: service stopped)

## Objective

Simulate a scenario where the Wazuh agent shows as `Disconnected` in the dashboard due to the service being stopped, and document the diagnostic and resolution process.

## Initial setup

- Wazuh agent active (`Active` status in the dashboard)
- Agent IP: `192.168.200.3` (Linux VM)
- Manager: `192.168.200.2`

---

## 1. Trigger the error

On the Linux agent:

```bash
sudo systemctl stop wazuh-agent
```

> The dashboard shows the agent as `Disconnected`

---

## 2. Diagnostic process

### 2.1 Observe the symptom (on the server)

Access the Wazuh Dashboard and confirm the agent is `Disconnected`.

### 2.2 Test basic connectivity (from server to agent)

```bash
ping 192.168.200.3
```

Result: Responds. IP connectivity between server and agent is working.

### 2.3 Access the agent for local investigation

```bash
ssh desktop1@192.168.200.3
```

### 2.4 Check service status (on the agent)

```bash
sudo systemctl status wazuh-agent
```

output:

```text
desktop1@desktop1-VirtualBox:~$ sudo systemctl status wazuh-agent
[sudo] password for desktop1:
○ wazuh-agent.service - Wazuh agent
     Loaded: loaded (/usr/lib/systemd/system/wazuh-agent.service; enabled; pres>
     Active: inactive (dead) since Tue 2026-02-24 10:50:08 WET; 4min 9s ago
   Duration: 17h 44min 9.959s
    Process: 20829 ExecStop=/usr/bin/env /var/ossec/bin/wazuh-control stop (cod>
        CPU: 4min 34.733s

Feb 24 10:50:05 desktop1-VirtualBox systemd[1]: Stopping wazuh-agent.service - >
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-modulesd...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-logcollector...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-syscheckd...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-agentd...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-execd...
Feb 24 10:50:08 desktop1-VirtualBox env[20829]: Wazuh v4.14.3 Stopped
Feb 24 10:50:08 desktop1-VirtualBox systemd[1]: wazuh-agent.service: Deactivate>
Feb 24 10:50:08 desktop1-VirtualBox systemd[1]: Stopped wazuh-agent.service - W>
Feb 24 10:50:08 desktop1-VirtualBox systemd[1]: wazuh-agent.service: Consumed 4>
```

### 2.5 Check agent logs (on the agent)

```bash
journalctl -u wazuh-agent -n 20 --no-pager
```

```output
Feb 23 17:05:29 desktop1-VirtualBox systemd[1]: wazuh-agent.service: Consumed 2>
Feb 23 17:05:49 desktop1-VirtualBox systemd[1]: Starting wazuh-agent.service - >
Feb 23 17:05:49 desktop1-VirtualBox env[4033]: Starting Wazuh v4.14.3...
Feb 23 17:05:49 desktop1-VirtualBox env[4033]: Started wazuh-execd...
Feb 23 17:05:50 desktop1-VirtualBox env[4033]: Started wazuh-agentd...
Feb 23 17:05:51 desktop1-VirtualBox env[4033]: Started wazuh-syscheckd...
Feb 23 17:05:52 desktop1-VirtualBox env[4033]: Started wazuh-logcollector...
Feb 23 17:05:53 desktop1-VirtualBox env[4033]: Started wazuh-modulesd...
Feb 23 17:05:55 desktop1-VirtualBox env[4033]: Completed.
Feb 23 17:05:55 desktop1-VirtualBox systemd[1]: Started wazuh-agent.service - W>
Feb 24 10:50:05 desktop1-VirtualBox systemd[1]: Stopping wazuh-agent.service - >
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-modulesd...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-logcollector...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-syscheckd...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-agentd...
Feb 24 10:50:05 desktop1-VirtualBox env[20829]: Killing wazuh-execd...
Feb 24 10:50:08 desktop1-VirtualBox env[20829]: Wazuh v4.14.3 Stopped
Feb 24 10:50:08 desktop1-VirtualBox systemd[1]: wazuh-agent.service: Deactivate>
Feb 24 10:50:08 desktop1-VirtualBox systemd[1]: Stopped wazuh-agent.service - W>
Feb 24 10:50:08 desktop1-VirtualBox systemd[1]: wazuh-agent.service: Consumed 4>
```

Look for stop messages or erros. In this caso, no errors - the service was simply stopped.

### 2.6 Test connectivity from agent to server (on the agent)

```bash
ping 192.168.200.2
telnet 192.168.200.2 1514
```

Results:

- Ping responds
- Telnet connects

Network between agent and server is OK.

## 2.7 Check agent configuration (on the agent)

```bash
sudo cat /var/ossec/etc/ossec.conf | grep -A 5 "192.168.200.2"
```

## 2.8 Diagnosis conclusion

- Network working (ping, telnet)
- Configuration correct
- Service stopped
- Root cause: wazuh-agent service is not running

---

## 3. Resolution

On the agent:

```bash
sudo systemctl start wazuh-agent
sudo systemctl enable wazuh-agent
```

---

## 4. Verification

### 4.1 Service status (on the agent)

```bash
sudo systemctl status wazuh-agent
```

Output:

```text
● wazuh-agent.service - Wazuh agent
     Loaded: loaded (/usr/lib/systemd/system/wazuh-agent.service; enabled; preset: e>
     Active: active (running) since Tue 2026-02-24 10:56:12 WET; 22min ago
    Process: 21078 ExecStart=/usr/bin/env /var/ossec/bin/wazuh-control start (code=e>
      Tasks: 33 (limit: 2266)
     Memory: 314.8M (peak: 386.6M)
        CPU: 1min 5.382s
     CGroup: /system.slice/wazuh-agent.service
             ├─21100 /var/ossec/bin/wazuh-execd
             ├─21108 /var/ossec/bin/wazuh-agentd
             ├─21122 /var/ossec/bin/wazuh-syscheckd
             ├─21135 /var/ossec/bin/wazuh-logcollector
             └─21150 /var/ossec/bin/wazuh-modulesd

Feb 24 10:56:07 desktop1-VirtualBox systemd[1]: Starting wazuh-agent.service - Wazuh>
Feb 24 10:56:07 desktop1-VirtualBox env[21078]: Starting Wazuh v4.14.3...
Feb 24 10:56:07 desktop1-VirtualBox env[21078]: Started wazuh-execd...
Feb 24 10:56:08 desktop1-VirtualBox env[21078]: Started wazuh-agentd...
Feb 24 10:56:09 desktop1-VirtualBox env[21078]: Started wazuh-syscheckd...
Feb 24 10:56:09 desktop1-VirtualBox env[21078]: Started wazuh-logcollector...
Feb 24 10:56:10 desktop1-VirtualBox env[21078]: Started wazuh-modulesd...
Feb 24 10:56:12 desktop1-VirtualBox env[21078]: Completed.
Feb 24 10:56:12 desktop1-VirtualBox systemd[1]: Started wazuh-agent.service - Wazuh >
```

## 4.2 Dashboard (on the server)

The agent returns to `Active` status

---

## 5. Key takeaways

- Diagnosis should test layers separately:
  1. Network (ping, telnet)
  2. Service (systemctl)
  3. Configuration (ossec.conf)
  4. Logs (journalctl)
- Not all diagnostics happen on the server - for local issues (service, config), you need to access the agent
- Documenting the process helps solve issues faster next time and shows your reasoning.
