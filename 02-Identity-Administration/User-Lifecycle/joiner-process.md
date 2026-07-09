# Joiner Process

## Overview

This lab walks through onboarding a new employee in Microsoft 365 and Microsoft Entra ID. I created a new identity, set up the profile, assigned the right licensing, established who the person reports to, and got the account ready for day one.

---

## Business Scenario

52 Logistics hired a new IT Support Technician, Christopher Young.

Before he could start, I needed to:

- Create the user account
- Assign Microsoft 365 licenses
- Configure profile information
- Assign his manager
- Verify the account was set up correctly
- Confirm he showed up in both the Microsoft 365 Admin Center and Microsoft Entra ID

---

# Administrative Tasks Performed

## User Creation

Created a new cloud-only user account from the Microsoft 365 Admin Center.

Configured:

- Display Name
- Username (UPN)
- Initial Password
- Usage Location

---

## License Assignment

Assigned the licenses his role actually needed:

- Microsoft 365 Business Premium
- Microsoft 365 Business Standard
- Microsoft Power Automate Free

Nothing extra tacked on, just what the job requires.


## Profile Configuration

Filled out his profile:

- Job Title
- Department
- Office Location
- Address
- Mobile Number

A complete profile is what makes the org directory, Teams, and Exchange actually show accurate information about him.

## Manager Assignment

Set Sofia Martinez as Christopher's manager.

That one field feeds into:

- Org charts
- Teams hierarchy
- Outlook org info
- Approval workflows
- Identity governance

---

## Verification

Checked that everything took:

- User shows up in Active Users
- Licenses assigned correctly
- Profile information saved
- Manager relationship set

---

## PowerShell Automation

I also automated the same onboarding workflow using Microsoft Graph PowerShell. The script:

- Created the user
- Updated profile information
- Assigned the manager
- Verified the account was created successfully

So this covers both sides, doing it by hand through the GUI, and doing it through automation.


## Skills Demonstrated

- Microsoft 365 Administration
- Microsoft Entra ID
- User provisioning
- License assignment
- Identity management
- Organizational hierarchy
- Microsoft Graph PowerShell
- Administrative automation

---

## Outcome

Christopher Young's account was fully provisioned and ready for day one, using both the standard GUI process and a PowerShell script to automate it.