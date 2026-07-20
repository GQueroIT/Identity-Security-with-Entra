# Identity Security with Entra

This project is a simulation of inheriting and securing a Microsoft Entra ID tenant for a fictional logistics company, 52 Logistics LLC, built on a real Microsoft 365 developer tenant rather than a sandbox with no consequences. Every finding, every mistake, and every decision documented here happened against an actual tenant with actual configuration, not a walkthrough of a tutorial.

I built it this way on purpose. Anyone can follow a Microsoft Learn module and take a screenshot. What I wanted to demonstrate is what it actually looks like to inherit an environment nobody has secured yet, figure out what's actually wrong with it, and fix it in a defensible order, the same job an Identity and Access Administrator does on day one at a real company.

---

## The Scenario

52 Logistics LLC is a fictional single-region logistics company with a distributed workforce, dispatchers, warehouse staff, and drivers accessing company systems from a mix of managed devices, personal devices, and locations well outside a traditional office. Going in, I assumed nothing about the tenant's security posture. The assessment phase confirmed what a company at this stage usually looks like: privileged access broader than it needed to be, no Conditional Access layered on top of Microsoft's baseline defaults, and self-service password reset disabled tenant-wide.

Everything after that assessment is the work of closing those gaps in a real, prioritized order, and documenting the reasoning behind every decision along the way.

---

## Why I Built It This Way

This tenant runs on a real Microsoft 365 developer subscription with a hard access-expiration clock, not a permanent lab environment. That constraint shaped the whole project. I couldn't wait around for organic risk signals or real sign-in history to accumulate, so I generated real test evidence deliberately, through the Microsoft Graph API, through Tor Browser sign-ins to trigger anonymous IP detections, through on-demand workflow runs instead of waiting on scheduled triggers. Every phase is documented with the actual screenshots and outcomes from that evidence, not staged results.

I also structured the project to align with the domains covered by the SC-300 Identity and Access Administrator certification, since the skills that certification tests are the same skills this kind of engagement actually requires.

---

## Project Structure

**00 - Executive Summary**
Overview of the engagement, the business context, and the objectives going in.

**01 - Tenant Assessment**
Baseline findings before any changes were made: three Global Administrators including an improperly isolated break-glass account, the tenant relying entirely on Security Defaults with no Conditional Access, and SSPR disabled tenant-wide.

**02 - Identity Administration**
Identity architecture decisions, the full joiner, mover, and leaver lifecycle, guest user planning, administrative units mapped for future delegation, and ten department-based security groups built through a PowerShell script against Microsoft Graph.

**03 - Authentication**
Smart lockout tightened, a custom banned password list built for the organization specifically, a custom authentication strength requiring phishing-resistant methods, SSPR enabled to close the Phase 01 finding, and a registration campaign to move users toward stronger authentication.

**04 - Conditional Access**
Security Defaults disabled and replaced with role-differentiated policies: phishing-resistant authentication for admin roles, session controls for privileged accounts, a geo-based block reflecting the company's actual footprint, and guest access restrictions. Documents a real sequencing mistake and the discovery that Microsoft auto-deploys managed policies as a safety net when Security Defaults is disabled without a custom policy in place.

**05 - Identity Protection**
Entra ID P2 trial activated and licensed to three accounts under a deliberate least-privilege count. Built risk-based Conditional Access policies and generated real risk signals to validate them. One policy caught and self-remediated a live risky sign-in with no admin intervention required.

**06 - Privileged Access**
Three Privileged Identity Management scenarios, each configured differently based on the actual risk of the role: self-service activation for routine account work, approval-gated activation for a higher-privilege role, and PIM for Groups bundling two roles behind a single activation for a task that genuinely needed both. Documents a repeated configuration mistake and why it kept happening.

**07 - Identity Governance**
Access reviews closing the loop left open in Phase 06, entitlement management rebuilding the manual onboarding process from Phase 02 into a governed self-service request, and Lifecycle Workflows automating onboarding and offboarding tasks. Surfaced a real data-completeness gap and a licensing architecture finding that's now shaping a tenant-wide recommendation.

**Planned**
Workload identities, incident response, compliance mapping, a full change log, and a final lessons-learned writeup are still ahead.

---

## Skills Demonstrated

- Microsoft Entra ID administration end to end, from tenant assessment through governance
- Conditional Access policy design, sequencing, and validation
- Identity Protection and risk-based access control
- Privileged Identity Management, including PIM for Groups
- Access reviews, entitlement management, and Lifecycle Workflows
- Microsoft Graph PowerShell SDK and Graph API for automation
- Zero Trust and least-privilege architecture applied to a real environment, not a slide deck
- Root-cause troubleshooting against real platform behavior, not scripted scenarios

---

## Real-World Findings

This project treats operational friction as evidence, not a mistake to hide. A few examples that show up across the phases:

Microsoft auto-deploys a set of managed Conditional Access policies as a transitional safety net when Security Defaults is disabled without a custom policy already in place. Confirmed directly against Microsoft Learn documentation rather than assumed.

A short PIM eligibility window chosen for expedience in one phase created real friction in a later phase, and the honest fix was a longer eligibility window, not standing access.

A Lifecycle Workflows onboarding automation failed three times before running clean, each failure traced to incomplete test-user profile data that had already been flagged as a risk in an earlier phase and never backfilled.

Group-based licensing turned an explicit offboarding license-removal task into a redundant no-op, because removing a user from their licensed group already revoked the license as a side effect. That finding is now driving a tenant-wide licensing model recommendation.

---

## Tools and Technologies

- Microsoft Entra ID, including Entra ID P2 and the Governance Add-on
- Microsoft Graph PowerShell SDK and Microsoft Graph API
- Microsoft 365 Admin Center
- Privileged Identity Management, Identity Protection, and Identity Governance
- Tor Browser, used deliberately to generate real risk-detection evidence
- Git and GitHub for version control and documentation

---

## Repository StructureIdentity-Security-with-Entra

│
├── 00-Executive-Summary
├── 01-Tenant-Assessment
├── 02-Identity-Administration
├── 03-Authentication
├── 04-Conditional-Access
├── 05-Identity-Protection
├── 06-Privileged-Access
├── 07-Identity-Governance
│
├── PowerShell-Toolkit
│   └── Reusable Graph PowerShell scripts referenced across phases
│
└── Each phase folder contains its own README, decisions.md,
and supporting screenshots documenting real tenant evidence

--- 

## Related Work

This repository holds identity and access management content only. Tenant deployment, Intune administration, and general Microsoft 365 administration for 52 Logistics LLC live in a separate companion repository, MS365-Intune-Administrator, to keep the two bodies of work cleanly separated.

---

## Status

Phases 00 through 07 are complete and documented. Phases 08 through 12 are actively in progress. This tenant runs on a time-boxed developer subscription, so evidence and screenshots were captured deliberately throughout the project rather than gathered at the end.