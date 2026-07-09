# Lifecycle Decisions

## Overview

Managing identities isn't just about creating and deleting accounts. Every action I take needs to line up with security practices, business needs, and least privilege.

This document lays out the decisions I made across the Joiner, Mover, and Leaver lifecycle at 52 Logistics.

---

# Joiner Decisions

## Account Creation

Every new employee gets their own cloud identity in Entra ID.

Accounts are created using:

- Legal first and last name
- Company naming standard
- Unique User Principal Name (UPN)

I steer clear of shared accounts. They make it harder to track who actually did what.

## License Assignment

Licenses go out based on what the job needs, not just handing out everything available.

| Role | License |
|-------|----------|
| IT Support | Microsoft 365 Business Premium |
| Office Staff | Microsoft 365 Business Standard |
| Sales | Microsoft 365 Business Standard |

Sticking to just what's needed keeps costs down and keeps access from piling up.

## Profile Information

I fill out employee info during onboarding as much as possible.

Required:

- Job Title
- Department
- Office Location
- Manager

This is what keeps Teams, Outlook, reporting, and org charts accurate.

---

# Mover Decisions

## Role Changes

A promotion doesn't mean starting over with a new account. I just update:

- Job Title
- Department
- Manager
- Contact Information

Keeping the same identity means the audit history, OneDrive, mailbox, and app assignments all carry over.

## Permission Review

Any time someone changes departments, I check:

- Security Group Membership
- Microsoft 365 Licenses
- Administrative Roles
- Application Access
- Conditional Access Policies

If it's not needed anymore, it comes off.

## Principle of Least Privilege

Access should match what the person actually does right now. Once permissions from an old role aren't needed, I remove them.

---

# Leaver Decisions

## Immediate Security Actions

When someone leaves:

1. Revoke active sessions.
2. Block sign-in.
3. Remove administrative access.
4. Delete the account when it makes sense.

This cuts down the window where someone could still get in after they're gone.

## Account Recovery

Deleted accounts stay recoverable during Microsoft's retention window. That matters if:

- The deletion was a mistake.
- The employee comes back shortly after.
- Something still needs to be pulled from the account.

## Data Preservation

Before deleting anything for good, I check whether the business needs to hold onto:

- Exchange Mailbox
- OneDrive Data
- Microsoft Teams Data
- Audit Logs
- Compliance Records

What gets retained depends on the situation and whatever regulatory requirements apply.

---

# Administrative Best Practices

Across the whole lifecycle, I try to:

- Keep profile information accurate.
- Assign licenses based on actual need.
- Stick to least privilege.
- Review permissions after every role change.
- Document the significant actions.
- Cut off access immediately during offboarding.
- Check account status after major changes.

---

# Lessons Learned

This lab made it clear that identity management is more than creating accounts. Every stage of the lifecycle comes with decisions that affect security, licensing, reporting, and access.

Running through this in the Microsoft 365 Admin Center, Entra ID, and Microsoft Graph PowerShell showed me how the same tasks work by hand and how they can be automated once the environment gets bigger.

---

## Skills Demonstrated

- Identity Lifecycle Management
- Microsoft Entra ID
- Microsoft 365 Administration
- Least Privilege Administration
- License Management
- Administrative Decision Making
- Identity Governance Fundamentals
- Microsoft Graph PowerShell