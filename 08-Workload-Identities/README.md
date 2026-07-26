# Phase 08 – Workload Identities

## Overview

Every phase before this one secured people. Phase 08 secures the identities that are not people: the scripts, apps, and integrations that authenticate to the tenant on their own, hold standing permissions, and never get phished, offboarded, or asked to MFA. Workload identities are the fastest growing part of most tenants and the least watched, which makes them exactly the kind of thing a security-focused administrator should be able to inventory, harden, and constrain.

This phase closes the final SC-300 domain of the project. It also produced more live findings than any phase since the Natalie Lopez investigation, including one where the lab environment itself turned hostile in the middle of evidence collection.

---

# The Inventory That Audited Itself

The phase opened by paying a debt. Assumptions.md committed on day one to inventorying whatever service principals came with the tenant, and Phase 08 finally built the tool: Get-52Logistics-WorkloadIdentityInventory.ps1, a Graph PowerShell script that classifies every service principal as Microsoft first-party or non-Microsoft, then flags credentials, ownerless apps, and admin-consented high-privilege permissions.

First run, before touching anything: 212 service principals in a tenant nobody had ever customized. 210 were Microsoft first-party. The short list of everything else was fully explainable, which is the actual goal of an inventory, not a low number but an explained one.

The best finding of the night was sitting in the connection context. The script asked for two read-only scopes. The session token came back carrying Directory.ReadWrite.All and Group.ReadWrite.All, accumulated from every consent I had granted to Microsoft Graph Command Line Tools across five prior phases. Delegated consent stacks on a shared service principal, and every new session inherits the union of everything ever granted. The audit tool had quietly become the most privileged workload identity in the tenant.

So the centerpiece of the phase became fixing that with the same tool that found it. A dedicated app registration, 52Logistics-Automation, holding exactly the two application permissions the script needs and nothing else. The default User.Read came off because no user ever signs into this app. The credential is a certificate, not a client secret, twelve month validity, private key generated into my certificate store and never exported anywhere. The conversion itself was one auth block: the same script, unchanged below the connect line, now runs unattended with Get-MgContext showing AuthType AppOnly and no account in the session.

Then the converted script ran its own audit and flagged itself, because Directory.Read.All matches the high-privilege pattern. I expected a clean pass and did not get one, and the flag is correct. Read-only access to the entire directory is a reconnaissance kit if the credential leaks. An auditor that flags it and lets a human clear it is doing its job. The flag stays, the review is documented, and the same principle held twice in one night: an audit that errs loud beats one that errs quiet.

Four runs across the phase tracked the tenant changing in real time, 212 to 216 to 218, with every new service principal accounted for by an action taken hours earlier. That is the inventory proving itself as a recurring control, not a one-time report.

---

# Closing the Consent Front Door

The dev tenant shipped with user consent wide open, meaning any user was one convincing OAuth prompt away from granting a malicious app real access. Consent phishing runs through that door in real tenants every day, and closing it costs nothing.

User consent is now restricted to verified publishers requesting low-impact permissions, with the five basic sign-in scopes classified as the floor. Everything above that routes through the admin consent request workflow: the user hits an approval wall, writes a justification, and the request lands in a reviewer queue with email notification and a 30 day expiration.

The whole chain ran live with the standing test personas. Jordan Reed hit a 403 on a Graph query, requested consent for Group.Read.All with a real Tier 2 justification, and the request arrived in my reviewer mailbox with the justification attached. On approval, Jordan reran the identical query and got data. The same request, 403 then 200, twenty minutes apart, brackets the entire workflow.

The approval dialog earned its own decisions.md entry, because it says something most people miss: granting the request gave Graph Explorer that permission for every user in the organization. The requesting user is the trigger. The tenant is the scope. Every approval permanently grows the tenant's standing consent surface, which is exactly why the inventory from Lab 1 runs on a schedule, and the very next run caught Graph Explorer appearing in the non-Microsoft list, materialized by that single approval.

---

# SAML by Hand

The SSO lab took the harder road on purpose. Entra's gallery holds thousands of prefilled apps, and the creation panel actively recommended real freight platforms when I typed the app name. A real 52 Logistics should take the gallery app. This lab exists to demonstrate what the gallery prefills: 52Logistics-FreightPortal went in as a non-gallery application with the entity ID, reply URL, and claims configured by hand.

The access gate went up before the sign-in mechanism existed. Assignment required, IT department group from Phase 02 assigned, zero individual users. Deny-by-default from minute one, and the same group-based RBAC model from Phase 02 now extended to applications.

Claims got one deliberate customization: a department claim sourced from user.department, the same attribute the whole identity architecture has been built on since Phase 02. Saving the configuration also minted something I did not create, a three year token signing certificate, which makes three certificates in this phase with three distinct jobs: one proves an app to Entra, one proves Entra to a service provider, and one signs SAML assertions.

The validation split into a positive path and a negative path, and only one of them survived contact with reality.

---

# When the Test Environment Turned Hostile

The plan validated the SAML round trip against samltest.id, a long-running free test service provider. It is not that anymore. The domain lapsed and now serves a parking page full of ad tiles, and during evidence collection it produced a fake Microsoft Store installer prompt, "SafeDomain Guardian," GUID for a publisher, claiming it uses all system resources. Cancelled, session closed, machine verified clean.

The malware prompt was not even the biggest problem. The app's reply URL pointed at that parked domain, and a SAML assertion is a signed package of real directory attributes. Completing the SSO test would have POSTed a user's identity data to whoever owns that page now. The positive round-trip test was halted on that basis, and I would make the same call again: the test had become the vulnerability.

The evidence adapted. The Federation Metadata XML the tenant publishes carries the signing certificate and endpoints, the trust contract in its raw form. The negative test ran fully because the assignment gate fires inside Entra before any assertion exists: Natalie Lopez, unassigned, blocked with AADSTS50105, captured at her screen and in the sign-in logs. Her log row also demonstrates a detail worth knowing cold, Conditional Access Success sitting next to sign-in Failure on the same line, because CA and application assignment are independent gates and she cleared one before hitting the other.

Two lessons went into decisions.md permanently. Third-party test dependencies rot. And the hardened tenant is not the whole attack surface, because the workstation driving it is part of the same picture.

---

# CA08 and the Third License Clock

Conditional Access for workload identities requires Workload Identities Premium, so the phase closed by activating the trial and building the policy the licensing enables.

The trial activation was itself a finding: no confirmation dialog, no stated end date, no immediate billing record. The subscription eventually surfaced through the Licenses blade, 200 capacity, activated July 26, and the activation timestamp went straight into the trial tracker next to the P2 and Governance clocks, because an untracked license clock is the exact failure mode the project's licensing discipline exists to prevent. The licensing model is also different in kind: zero of 200 assigned, and everything works, because workload identity licensing is tenant capacity, not per-identity assignment. That makes the Lab 1 inventory the direct input to the spend decision, you pay per workload identity protected, so you count them first.

CA08-Block-Service-Principal-Outside-US targets the automation service principal and blocks it outside the US named location built in Phase 04. Same policy logic as CA03, applied to an identity type that CA01 through CA07 could not touch. The discipline held to the end: built in Report-only, validated against a real app-only sign-in showing the policy evaluate correctly, then enforced. A stolen certificate private key now works from inside one country's IP space, not from anywhere on earth.

The policy also carried the phase's honestly documented mistake: it initially went in with Principle in the name where Principal belongs, in the one repo whose purpose is demonstrating identity fluency. Renamed before the evidence captures, documented plainly, same treatment as every mistake in this project.

Final board: twelve Conditional Access policies, eight of them mine, seven enforced, CA07 parked in Report-only with a stated reason, and the newest one protecting an identity that cannot MFA, cannot be phished, and never leaves.

---

# Objectives

- Inventory every workload identity in the tenant and classify what was inherited
- Harden user consent and stand up the admin consent request workflow with live requestor and approver evidence
- Register a least-privilege automation application with certificate-based app-only authentication
- Convert a working toolkit script from delegated interactive auth to unattended app-only auth
- Configure non-gallery SAML SSO by hand with custom claims and group-based assignment
- Apply Conditional Access to a service principal under Workload Identities Premium
- Track a third concurrent license trial without losing a clock

---

# Technologies Used

- Microsoft Entra Admin Center
- Microsoft Graph PowerShell SDK
- Microsoft Graph Explorer
- Windows PowerShell and certificate store
- SAML 2.0 federation metadata
- Microsoft Entra Workload Identities Premium
- Microsoft 365 Admin Center billing
- Git and GitHub

---

# Skills Demonstrated

### Workload Identity Security

- Service principal inventory and classification
- Application registration and service principal object model
- Certificate-based credential management
- App-only authentication for unattended automation
- Least-privilege application permission scoping

### Consent Governance

- User consent restriction and permission classification
- Admin consent request workflow configuration
- Tenant-wide consent surface analysis

### Application Access

- Non-gallery SAML SSO configuration
- Custom claims mapping
- Group-based application assignment
- Federation metadata and signing certificate management

### Conditional Access

- Workload identity policy targeting
- Report-only validation and enforcement decisions
- Location-based constraint of automation identities

---

# Key Takeaways

The identities that run without people are the ones nobody watches, and this phase built the watching. The inventory script went from a delegated tool riding on accumulated admin consent to a properly credentialed workload identity that audits the tenant, and itself, on exactly two read-only permissions. The consent front door that every phishing kit targets is closed and gated behind a working approval chain with real evidence at both ends.

The phase also delivered its lessons the honest way. A test dependency died and turned hostile mid-lab, and the right response was stopping a test that had become the vulnerability. The application object and service principal split explained five different things that looked broken before it clicked. And the audit tool flagging its own permissions was not a bug to patch but a design working as intended.

Every workload identity in this tenant is now inventoried, owned, credentialed deliberately, and constrained by policy. That is what securing 52 Logistics looks like when the user list is not the whole story.