# Active Directory - Users and Groups Management

## Purpose

Learn how to populate your new domain with **Organizational Units (OUs)**, **users**, and **groups**. This is where Active Directory starts to become useful - creating the digital identities that represent people and resources in your lab.

## Prerequisites

- Domain Controller installed and running (`DC01`)
- Logged in as domain administrator (`LAB\Administrator`)
- Active Directory Users and Computers tool available

> **If you havent completed the [AD installation](./ad-installation.md), go back and do it first!** This guide builds on that setup.

---

## 1. Understanding OUs, Users, and Groups

Before we start clicking, let's understand what we're creating:

### 🗂️ **Organizational Units (OUs)**
- **What they are**: Like folders in a file system, but for AD objects
- **Why use them**: To organize users/computers by department, location, or function
- **Real world example**: "Sales", "IT", "HR", "Managers"
- **Superpower**: You can apply different policies to different OUs

### 👤 **Users**
- **What they are**: Digital identities for people (or service accounts)
- **What they store**: Username, password, name, email, department, etc.

### 👥 **Groups**
- **What they are**: Collections of users (or computers)
- **Why use them**: To assign permissions to multiple people at once
- **Superpower**: Instead of giving 20 users access to a folder, give it to one group

### 📊 **Visual Hierarchy Example**
```cmd
lab.local
├── Users (default container)
├── Computers (default container)
├── Domain Controllers (default container)
├── OUR_CUSTOM_OUs 👈
│ ├── IT
│ │ ├── Users
│ │ │ ├── carlos.tech
│ │ │ └── ana.sysadmin
│ │ └── Groups
│ │ └── IT-Admins
│ ├── Sales
│ │ ├── Users
│ │ │ ├── maria.sales
│ │ │ └── joao.vendas
│ │ └── Groups
│ │ └── Sales-Team
│ └── HR
│ ├── Users
│ │ └── patricia.hr
│ └── Groups
│ └── HR-Team
```

---

## 2. Creating Organizational Units (OUs)

### Step 2.1: Open Active Directory Users and Computers

1. On your Domain Controller (`DC01`), open **Server Manager**
2. Click **Tools** -> **Active Directory Users and Computers**
3. Your domain `lab.local` should be visible