# Groups

## Overview

52 Logistics LLC uses department-based security groups to implement the RBAC and least-privilege access model established in decisions.md. Rather than assigning licenses, permissions, or Conditional Access scope to individual users one at a time, access is managed at the group level, grouped by the department structure already reflected in each user's profile.

---

## Groups Created

Ten security groups were created, one per department represented in the tenant's user base: Executive, IT, HR, Finance, Sales, Operations, Warehouse, Compliance, Security, and Marketing. Each group was created as a security group, not mail-enabled, and populated by filtering existing users against their department attribute.

---

## Automation

Group creation and membership assignment was automated with Create-52Logistics-DepartmentGroups.ps1, found in PowerShell-Toolkit. The script creates each department's group, then queries Microsoft Graph for users matching that department and adds them as members. See troubleshooting.md for an issue encountered with the Graph query during this process.