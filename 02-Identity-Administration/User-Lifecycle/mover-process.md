# Mover Process

## Overview

This lab covers how an administrator handles a role change for an employee who's already onboarded. Instead of creating a new account, I update the existing identity so it reflects the new responsibilities, while keeping the employee's history, permissions, and reporting relationships intact.

---

## Business Scenario

Kevin Brown was promoted from IT Support Technician to Sales Manager.

As part of that promotion, I needed to update his profile so Microsoft 365 reflected his new position.

---

# Administrative Tasks Performed

## Updated Job Information

Modified his profile to reflect the new role.

Updated fields:

- Job Title
- Department

## Updated Contact Information

Reviewed and updated:

- Street Address
- City
- State
- Mobile Number

Keeping this current matters for directory searches, reporting, and just getting a hold of him when needed.

## Manager Relationship

Checked his reporting structure. This field shows up in more places:

- Microsoft Teams
- Outlook
- Org charts
- Approval workflows
- Identity Governance

## Account Verification

Confirmed the changes actually saved to Microsoft Entra ID:

- Updated Job Title
- Updated Department
- Contact Information
- Account Status
- User Principal Name (UPN)

---

## PowerShell Automation

I ran through the same promotion using Microsoft Graph PowerShell:

- Updating user properties
- Modifying job information
- Updating department
- Updating contact information
- Verifying the updated account

In a larger environment, scripting this keeps every promotion handled the same way instead of relying on someone remembering all the steps.

---

## Administrative Considerations

A role change isn't just a title update. I also check whether the employee needs:

- Different Microsoft 365 licenses
- Membership in new security groups
- Removal from old groups
- Updated application assignments
- Different administrative roles
- Updated Conditional Access policies