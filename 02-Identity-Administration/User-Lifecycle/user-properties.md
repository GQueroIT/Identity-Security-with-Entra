# User Properties

## Overview

This lab digs into the user attributes available in Microsoft Entra ID and Microsoft 365. These properties are what everything else runs on: authentication, admin tasks, reporting, app integration all pull from this same identity information.

Keeping these accurate is what lets people get the right access and lets the org function the way it's supposed to.

---

## Business Scenario

At 52 Logistics, employee profiles need accurate organizational and contact information from the moment someone's onboarded and for as long as they're employed.

Keeping those attributes current throughout the employee's time here falls on the administrator.

---

# Properties Reviewed

Here's what I looked at and updated in this lab.

## Identity Information

- Display Name
- First Name
- Last Name
- User Principal Name (UPN)
- Object ID
- User Type
- Creation Date

These are what make each user unique inside Entra ID.

## Job Information

Updated:

- Job Title
- Department
- Company Name

This information feeds into:

- Microsoft Teams
- Outlook
- Org Charts
- Identity Governance
- Dynamic Group Membership

## Contact Information

Configured:

- Office Location
- Street Address
- City
- State
- Postal Code
- Country
- Mobile Phone
- Business Phone

This is what keeps the directory usable and makes it possible for people to actually reach each other.

## Account Settings

Reviewed:

- Account Enabled
- Usage Location
- Assigned Licenses
- Preferred Language
- Password Information

These settings control how the account actually behaves inside the tenant.

## Organizational Information

Verified:

- Assigned Manager
- Department
- Reporting Structure

The manager field is what builds out the org hierarchy and drives approval workflows.

---

## Microsoft Graph PowerShell

Pulled the same user properties through Microsoft Graph PowerShell:

- Display Name
- User Principal Name
- Department
- Job Title
- Office Location
- Account Status

This is where PowerShell earns its keep, pulling user info in bulk and automating reporting instead of clicking through each account one at a time.

---

## Administrative Considerations

Accurate properties are what make these actually work:

- User search results
- Microsoft Teams profiles
- Outlook directory information
- Dynamic group membership
- Administrative reporting
- Identity Governance
- Access reviews
- Automation workflows

Let a profile go stale and every one of those starts breaking down quietly.

---

## Skills Demonstrated

- Microsoft Entra ID
- Microsoft 365 Administration
- User Identity Management
- Profile Management
- Microsoft Graph PowerShell
- Organizational Hierarchy
- Administrative Reporting

---

## Outcome

Reviewed and managed user identity attributes across both the Microsoft 365 Admin Center and Microsoft Entra Admin Center, confirmed the profile data stayed consistent between them, and pulled the same properties through Microsoft Graph PowerShell for reporting and automation.