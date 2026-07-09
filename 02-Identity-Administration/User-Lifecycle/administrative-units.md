# Administrative Units

## Overview

Administrative Units let me delegate admin responsibility over a specific slice of users, groups, and devices in Entra ID instead of handing someone access to the whole directory. I can scope permissions down to a business unit, department, or location.

This is least privilege in practice, an admin only touches what they're actually responsible for.

## Business Scenario

As 52 Logistics grows, IT wants to hand off routine identity tasks to regional administrators instead of giving everyone tenant-wide access. Each regional admin would only manage the users tied to their location.

Possible Administrative Units:

- New York HQ
- Northeast Distribution Center
- Southeast Distribution Center
- Corporate IT

This keeps the risk contained while still letting regional IT actually do their job.

## Administrative Unit Benefits

Administrative Units let me:

- Delegate admin work without opening up the whole tenant.
- Limit how far an administrator's scope reaches.
- Keep departments separated.
- Support regional administration.
- Tighten security through least privilege.

## Common Administrative Roles

Roles that can be scoped to an Administrative Unit:

- User Administrator
- Helpdesk Administrator
- Groups Administrator
- Authentication Administrator
- Password Administrator

An admin assigned to a unit can only manage what's inside it, nothing outside that boundary.

## Administrative Planning

When I'm designing Administrative Units, I'm thinking about:

- Geographic locations
- Business departments
- Organizational structure
- Administrative responsibilities
- Compliance requirements

The units need to match how the business actually operates, not just copy the org chart for the sake of it.

## Relationship to RBAC

Administrative Units work alongside RBAC, but they're answering different questions.

RBAC decides what an administrator can do.

Administrative Units decide who or what they can do it to.

Put together, that's how I get granular, delegated administration instead of an all-or-nothing setup.

## Best Practices

- Delegate only what's actually needed.
- Keep the scope as small as it can practically be.
- Review delegated assignments regularly.
- Document who owns which Administrative Unit.
- Pull access back when responsibilities change.

## Skills Demonstrated

- Microsoft Entra ID
- Administrative Delegation
- Role-Based Access Control (RBAC)
- Least Privilege Administration
- Identity Governance
- Microsoft 365 Administration

## Outcome

Went through how Administrative Units work in Entra ID and what they're for. I didn't actually configure them in this phase, the tenant's too small to need it yet, but I mapped out how they'd fit into delegated administration and least privilege for 52 Logistics down the line.