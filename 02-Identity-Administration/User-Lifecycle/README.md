# Section 02 – User Lifecycle Management

## Overview

This section demonstrates how I implemented and managed the complete Microsoft 365 user lifecycle within the 52 Logistics tenant. The objective was to simulate real-world identity administration tasks performed by Microsoft 365 and Entra ID administrators while documenting each stage of the employee lifecycle.

Rather than treating each lab as an isolated exercise, I combined them into a continuous workflow that reflects how user administration occurs in production environments. Throughout this section I worked directly in Microsoft 365 Admin Center, Microsoft Entra Admin Center, and Microsoft Graph PowerShell to perform the same administrative tasks from both the graphical interface and the command line.

---

# Objectives

- Create new Microsoft 365 users
- Assign Microsoft 365 licenses
- Configure user profile information
- Establish manager relationships
- Modify employee information after role changes
- Reset user passwords
- Revoke active user sessions
- Block user sign-in
- Delete user accounts
- Restore deleted users
- Perform lifecycle operations using Microsoft Graph PowerShell

---

# Technologies Used

- Microsoft 365 Admin Center
- Microsoft Entra Admin Center
- Microsoft Graph PowerShell SDK
- Microsoft Graph API
- PowerShell 7
- Git
- GitHub

---

# Lifecycle Workflow

## Joiner

A new employee is onboarded into the organization.

Tasks performed:

- Created Microsoft 365 user accounts
- Assigned Business Standard and Business Premium licenses
- Configured department information
- Assigned job titles
- Added office location
- Configured contact information
- Assigned managers
- Verified account creation

---

## Mover

An existing employee changes positions inside the organization.

Tasks performed:

- Updated job title
- Changed department
- Updated office location
- Updated contact information
- Changed reporting manager
- Reviewed licensing
- Verified updated profile information

---

## Leaver

An employee leaves the organization.

Tasks performed:

- Revoked active sessions
- Reset password
- Blocked sign-in
- Deleted user account
- Verified account moved into Deleted Users
- Restored account during retention period
- Verified restored account

---

# PowerShell Automation

The same lifecycle process was automated using Microsoft Graph PowerShell.

The automation script performs:

- Create user
- Configure profile
- Assign manager
- Promote employee
- Revoke active sessions
- Block sign-in
- Delete account
- Restore deleted account
- Verify restored user

This demonstrates that lifecycle management can be performed consistently through automation rather than manual administration.

---

# Repository Contents

```
02-User-Lifecycle-Management
│
├── Documentation
│   ├── joiner-process.md
│   ├── mover-process.md
│   ├── leaver-process.md
│   ├── user-properties.md
│   ├── guest-users.md
│   ├── administrative-units.md
│   ├── lifecycle-decisions.md
│   └── lifecycle-troubleshooting.md
│
├── Diagrams
│   ├── joiner-workflow.png
│   ├── mover-workflow.png
│   ├── leaver-workflow.png
│   └── user-lifecycle-overview.png
│
├── Screenshots
│
├── Powershell
│   ├── Invoke-UserLifecycleDemo.ps1
│   └── supporting scripts
│
└── README.md
```

---

# Skills Demonstrated

### Identity Administration

- User provisioning
- Identity management
- Employee lifecycle administration
- User profile management
- Organizational hierarchy

### Microsoft 365 Administration

- License assignment
- User management
- Password administration
- Session management
- Manager assignments

### Microsoft Entra ID

- Identity lifecycle
- Deleted user recovery
- Account restoration
- Sign-in management
- Directory administration

### PowerShell Automation

- Microsoft Graph SDK
- Microsoft Graph authentication
- User creation
- Property updates
- Lifecycle automation
- Administrative scripting

---

# Troubleshooting

During development I encountered several issues that required troubleshooting.

Examples included:

- Restoring deleted users through Microsoft Graph
- Resolving Microsoft Graph object lookup errors
- Handling deleted object IDs
- Verifying restored identities
- Allowing directory replication after restore operations

These troubleshooting steps are documented in **lifecycle-troubleshooting.md**.

---

# Key Takeaways

Completing this section gave me practical experience managing user identities throughout their entire lifecycle using Microsoft's cloud administration tools. I performed every operation through both the Microsoft 365 Admin Center and Microsoft Entra Admin Center before automating the same workflow with Microsoft Graph PowerShell.

Working through the lifecycle from onboarding to restoration reinforced how closely identity management is tied to security, licensing, organizational structure, and operational efficiency. It also highlighted how automation can reduce administrative effort while maintaining consistency across repetitive identity management tasks.

---

## Next Section

➡️ **Section 03 – Group Management**

Topics include:

- Security Groups
- Microsoft 365 Groups
- Mail-enabled Security Groups
- Distribution Lists
- Dynamic Membership Rules
- Nested Groups
- Role Assignable Groups
- Microsoft Graph Group Automation