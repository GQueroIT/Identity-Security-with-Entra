# Phase 08 Decisions: Workload Identities

This phase closed the last SC-300 domain the project had not touched: application and workload identity security. Five labs, three new certificates, a third license trial, and an inventory script that ended the night auditing itself under its own identity. It also had the most live findings of any phase since 05, including one where the environment itself turned hostile mid-lab.

---

# Lab 1: Workload Identity Inventory

## Decision: Run the inventory before changing anything

**Context:** Assumptions.md committed on day one to inventorying whatever service principals came with the tenant. The project never circled back to it, and Phase 08 was about to add several new workload identities of its own.

**Decision:** Built Get-52Logistics-WorkloadIdentityInventory.ps1 and ran it read-only before any other Phase 08 work, so the output reflects the tenant as inherited. First run: 212 service principals, 210 Microsoft first-party, 2 non-Microsoft, both ownerless, both explainable. Microsoft Graph Command Line Tools existed because of my own consent across earlier phases. O365 LinkedIn Connection ships with M365 tenants.

## Decision: Deny the tenant-wide consent checkbox on my own script

**Context:** Connecting the script prompted for Application.Read.All and Directory.Read.All as delegated scopes. Because I am a Global Admin, the prompt pre-checked "Consent on behalf of your organization," which would have granted those scopes to every user in the tenant silently.

**Decision:** Unchecked it and consented for my account only. I am the only person running this inventory, so a tenant-wide grant had no justification. Even as the admin, the per-user grant did the job. Same least-privilege posture as the P2 license scoping in Phase 05, applied to consent itself.

## Finding: The inventory tool was the most privileged workload identity in the tenant

The Get-MgContext output after the first run showed the session carrying Directory.ReadWrite.All and Group.ReadWrite.All. The script asked for two read-only scopes. The write scopes were riding along because delegated consent on Graph Command Line Tools accumulates: every phase where I consented to something, group creation in Phase 02, CA policy work in Phase 04, stacked onto the same service principal, and any session through it carries the union of everything ever granted. The audit tool had quietly become the most privileged workload identity in the tenant. This finding is the direct justification for Lab 3.

The zero high-privilege application permissions in the same run is consistent with this, because the accumulated scopes are delegated and only work with me signed in. The distinction between a delegated pile-up and a standing application grant is core SC-300 material and the tenant demonstrated it on its own.

## Finding: The classification heuristic over-flags, and that is the safe direction

O365 LinkedIn Connection is Microsoft-published but landed in the non-Microsoft bucket, because its owning organization is not one of the two Microsoft service tenant IDs the script matches against. That is a heuristic hitting its limit, and the failure mode points the right way: the script forced me to verify an app I would otherwise have scrolled past. An inventory that over-flags beats one that under-flags.

---

# Lab 2: Consent Hardening

## Decision: Restrict user consent to the middle setting

**Context:** The dev tenant shipped with user consent wide open. Any user was one convincing OAuth prompt away from granting a malicious app real data access. Consent phishing is an active, current attack technique and this is its front door.

**Decision:** Set user consent to allow consent for apps from verified publishers, for selected permissions only. Full lockout was the other candidate, and it loses on operational grounds: it routes every OAuth prompt to the reviewer, including harmless sign-in flows, and a flooded approver starts rubber-stamping. The middle setting blocks the dangerous grants while letting verified publishers request basic profile scopes. The policy filters, which is what lets it scale.

Classified the five basic sign-in permissions as low impact: User.Read, offline_access, openid, profile, email. The portal itself notes only delegated permissions that do not require admin consent can be classified here, which is the platform confirming that application permissions can never be user-consentable regardless of classification. That boundary is exactly why Lab 3's automation app routes through admin consent.

Classifying permissions does nothing on its own. The classification only takes effect once User consent settings points at it, a sequencing detail that is easy to miss.

## Decision: Configure the admin consent request workflow with a user reviewer

**Context:** With user consent restricted, users need a paved path to request access, or the restriction just becomes shadow IT pressure.

**Decision:** Enabled the workflow with myself as reviewer, email notifications on, and the default 30 day request expiration left in place. The reviewer picker offers Groups and Roles, both marked Preview. User-based assignment is what is production-ready today, so that is what got configured, with role-based assignment noted as where this should land once GA, for the same reason Phase 02 assigned access through groups: reviewer coverage should survive personnel changes.

The 30 day expiration is a platform default acting as a safety net against requests rotting in a queue, the same design instinct as the 14 day decision window entitlement management applied uninvited in Phase 07.

## Finding: Review and grant are separate powers

The reviewer panel's own fine print: anyone selected can review, block, and deny, but only Global Administrator, Application Administrator, or Cloud Application Administrator holders can actually grant. A reviewer without one of those roles is a triage function, not an approval authority. In a real org that means the queue can be staffed with people who filter the junk while the grant stays gated behind privileged roles. The platform enforces the split whether you noticed it or not.

## Finding: The workflow works, and the requestor gets told almost nothing

The live test ran the full chain as Jordan Reed: GET /groups in Graph Explorer returned 403 Authorization_RequestDenied, the consent attempt on Group.Read.All produced the Approval required dialog with a justification box, and the request was submitted with a real Tier 2 justification. The confusing part: the first screen after submission was a generic "Need admin approval" page that reads like a dead end. The actual "Request pending, your admin has been notified" confirmation only appeared after the redirect finished. A real helpdesk user hits that first screen and files a ticket asking whether their request went through. The workflow is solid. The requestor feedback arrives one confusing screen late.

The reviewer email arrived in Exchange, which turned out to be provisioned all along through the Business licenses even though nobody at 52 Logistics had ever opened a mailbox. The email independently confirmed the 30 day window: request dated July 26, review by August 25.

## Finding: Approving one user's request grants the whole tenant

The approval dialog said it plainly: this app will get access to the specified resources for all users in your organization. Approving Jordan's request did not grant Jordan anything individually. It granted Graph Explorer Group.Read.All tenant-wide, with Jordan as the trigger and the tenant as the scope. This is the part of the admin consent workflow most people misunderstand, and it is why every approval through this workflow permanently grows the tenant's standing consent surface. That growth is exactly what the Lab 1 inventory exists to catch on a recurring basis, and the next run proved it: Graph Explorer appeared in the non-Microsoft list, materialized by this approval.

The evidence bracket closed with Jordan rerunning the identical query and getting 200 with real group data, 403 and 200 on the same request about twenty minutes apart. One wrinkle worth knowing: after consent succeeded, the response pane still displayed the old 403, because it holds the last run and does not re-evaluate. The rerun produced the 200.

---

# Lab 3: App Registration and App-Only Automation

## Decision: Convert the inventory script, out of three candidates

**Context:** The centerpiece lab needed a real script to move from delegated interactive auth to app-only. The toolkit offered three candidates: group creation, CA policy creation, and the inventory.

**Decision:** The inventory, for three reasons. It is the only script with a genuine unattended future, a real org runs an inventory on a schedule, and scheduled means no admin at a keyboard. It is read-only, so the permission grant is defensible: Application.Read.All and Directory.Read.All, and a leaked credential means disclosure, not modification. Converting the group script would have handed a standing identity Group.ReadWrite.All, and the CA script Policy.ReadWrite.ConditionalAccess, grants my own audit flags as high-privilege. And it closes the Lab 1 loop: the same tool that surfaced the accumulated-scope problem becomes the fix, running as its own identity with exactly two read permissions.

## Decision: Certificate credential, twelve months, private key never leaves the machine

**Context:** The registration needed a credential, and the choice is client secret or certificate.

**Decision:** Self-signed certificate, 2048-bit, SHA256, twelve month validity expiring 7/26/2027. A client secret is a string that travels. A certificate private key is a thing that stays: it lives in my user certificate store, was never exported, and appears in no screenshot. Only the public key went to Entra. The credentials blade itself recommends certificates over secrets for higher assurance, so the platform documentation endorses the decision on the same screen as the implementation. Twelve months is long enough to be realistic and short enough to force a rotation conversation, and in production this pairs with an expiration alert.

The exported .cer landed outside the repo, and *.cer went into .gitignore. Credential material stays out of version control by policy, enforced by ignore rules, not by memory.

## Decision: Single tenant, no redirect URI, and strip the default User.Read

**Context:** Registration choices that each had a reason.

**Decision:** Single tenant because nothing outside 52 Logistics ever authenticates as this app, and because Conditional Access for workload identities only applies to single-tenant service principals, making this checkbox a Lab 5 dependency. No redirect URI because nothing signs in interactively, so there is nowhere to redirect. And the default delegated User.Read permission Microsoft adds to every registration came off: the app never signs a user in, so nothing delegated belongs on it. Entra pushed back with a generic "this scope is required for proper application functionality" warning, which assumes the app might sign users in. It will not, so the warning did not apply, and being able to say why it was overridden matters more than a removal with no pushback.

Final permission state: two application permissions, both read-only, both admin-consented, zero delegated, zero secrets, one certificate.

## Decision: The conversion is one auth block

The entire code change from delegated to app-only was swapping the Connect-MgGraph line from interactive scopes to ClientId, TenantId, and CertificateThumbprint. Everything below the connect line ran unchanged. Get-MgContext after the run: AuthType AppOnly, TokenCredentialType ClientCertificate, Account blank, AppName 52Logistics-Automation. No user exists in the session. That output next to Lab 1's Delegated and InteractiveBrowser context is the whole lab in two artifacts.

## Finding: The auditor flagged itself, and the flag is correct behavior

The app-only run put 52Logistics-Automation in its own high-privilege list, because Directory.Read.All matches the script's Directory.* pattern. I had expected the app to pass its own audit clean, and it did not, and after sitting with it the flag is right. Directory.Read.All is read-only, but it reads the entire directory, and a leaked credential with that scope is a full reconnaissance kit. An auditor that flags it for review and lets a human clear it is working as designed. The flag stays, this entry is the documented review, and the conclusion matches the LinkedIn misclassification from Lab 1: an audit that errs loud beats one that errs quiet.

## Finding: Credentials on the application object are invisible to a service principal inventory

The run showed the automation app carrying zero credentials, an hour after I uploaded a certificate to it. The certificate lives on the application object. The script inventories service principals. Credentials can sit on either object, and the script reads one side. Catching app-registration credentials means adding a Get-MgApplication pass, which goes on the toolkit backlog as a stated enhancement, not a silent patch.

## Mistake: Assigned the owner to the wrong object first

The run flagged the automation app as ownerless, a real finding, an app with no owner has no accountable human when the certificate needs rotating. I added myself as owner on the app registration, and the fix was incomplete: the script reads owners on the service principal, which is a separate object with a separate owner list. Re-fixed on the Enterprise applications side. The Enterprise app Owners blade even states it in its own fine print: the separate list of owners who maintain the application registration is on the application registration. Two more details from that blade worth keeping: group ownership of applications is not supported yet, so this is one governance surface where the Phase 02 group model cannot extend, and any Global Admin can manage every app regardless of the owners list, which makes ownership here accountability metadata, not an access control.

---

# Lab 4: Non-Gallery SAML SSO

## Decision: Non-gallery, with the portal actively suggesting gallery apps

**Context:** Creating 52Logistics-FreightPortal, the app creation panel matched the name against the gallery and recommended FreightPOP, Freightos, and others, with Microsoft's own text recommending gallery applications when possible.

**Decision:** Non-gallery, deliberately. A real 52 Logistics onboarding a real freight platform should take the gallery app. This lab exists to demonstrate the manual work the gallery prefills: entity ID, reply URL, signing certificate, and claims mapping configured by hand, which is the substantive SC-300 material.

## Decision: Gate before mechanism

**Context:** A new enterprise app needs both an access gate and a sign-in mechanism, and the order matters.

**Decision:** Assignment required confirmed Yes and the IT department group from Phase 02 assigned before any SAML configuration existed. Deny-by-default from minute one, and access managed at the group level, zero individual users. The assignment toast said it in one line: 0 users and 1 group have been assigned access. The role column showed the single default app role every non-gallery app ships with, and the same mechanism scales to role-differentiated access, admin, approver, viewer, when an app defines more.

## Decision: One custom claim, bare-named

**Context:** The default claim set covers givenname, surname, emailaddress, and name, all under full schema URIs, plus the UPN as the required NameID.

**Decision:** Added a department claim sourced from user.department, the same attribute the Phase 02 groups and the Phase 05 lifecycle work were built on. Left the namespace empty, so it went out bare-named where the defaults carry schema URIs. Both are valid SAML, and the difference marks where the standard vocabulary ends and org-specific claims begin: defaults use the common schema so any SP recognizes them, custom claims are a contract defined with the specific SP consuming them.

Saving the SAML configuration also minted a token signing certificate automatically, a three year cert expiring 7/26/2029 with rotation notification pointed at my mailbox. Third certificate of the night, third distinct job: the automation cert proves an app's identity to Entra, this one proves Entra's identity to a service provider. When it rolls, every SP trusting it breaks until metadata is re-exchanged, which is what the notification email field exists for.

## Constraint: The test service provider's domain had lapsed, and the replacement was hostile

**Context:** The plan used samltest.id, a long-running free SAML test SP, for the round-trip validation.

**Decision and what happened:** The domain is dead. It now serves a domain-parking page with ad tiles, and during evidence collection it produced a fake Microsoft Store installer prompt for "SafeDomain Guardian" from mispg.safedomainguard.online, GUID for a publisher name, "uses all system resources" as its capability. Cancelled, closed the session, verified nothing installed. Nothing in this lab installs software, and no legitimate Store app describes itself that way.

The immediate security implication was bigger than the malware prompt: the app's reply URL pointed at that parked domain, and a SAML assertion is a signed package of real directory attributes. Completing an SSO test would have POSTed a user's identity data to whoever owns that page now. The positive round-trip test was halted on that basis. Stopping the test because completing it had become the vulnerability was the correct call, and it is a sharper security judgment than a successful round trip would have demonstrated.

Two lessons out of it. Third-party test dependencies rot, and a rotted one nearly delivered a payload to the admin workstation mid-lab. And the hardened tenant is not the whole attack surface, the workstation driving it is part of the same picture.

## Decision: Prove the claims through the metadata, prove the gate through the negative test

**Context:** With the SP round trip off the table, the evidence had to come from what the tenant itself publishes and blocks.

**Decision:** The downloaded Federation Metadata XML serves as the trust contract evidence: the X509 signing certificate embedded as the trust anchor, the endpoints, and the tenant's claim vocabulary. One precision note so the evidence is described accurately: the ClaimTypesOffered section in that file is the tenant's standard claim vocabulary advertisement, which is why it includes types never configured on this app. The app-specific claim mapping, including the department claim, is evidenced by the portal configuration. Together they cover the claims story, and captioning the metadata as showing the custom claim would be wrong.

The negative test ran fully, because the assignment check fires inside Entra before any assertion is generated, so nothing touches the parked domain. Natalie Lopez, unassigned, hit AADSTS50105, not assigned to a role for the application, captured at the error screen and in the app's own sign-in log filtered to FreightPortal. Same negative-evidence pattern as Phase 04, applied to SSO.

## Finding: Conditional Access Success next to sign-in Failure is not a contradiction

Natalie's failed sign-in row shows Conditional Access: Success. CA evaluated her and no policy blocked her, US-based, not risky, MFA satisfied, so CA reports Success, and the sign-in then failed on the assignment check, a separate gate that fires after Conditional Access passes. Two independent doors, she cleared the first and hit the second. This phase has now demonstrated three distinct gates in the sign-in path with separate evidence: Conditional Access, application assignment, and consent. Each fails independently of the others, which is what defense in depth means when it is concrete.

---

# Lab 5: Workload Identities Premium and CA08

## Decision: Activate the trial, third clock on the tenant

**Context:** Conditional Access for workload identities and service principal risk detection require Workload Identities Premium. The alternative was a documented scope-out.

**Decision:** Activated. The scenario CA08 addresses is the one the phase built toward, constraining where a certificate-authenticated automation identity can be used, and demonstrating the licensed capability is the point of the lab.

The activation experience is itself a finding. The in-Entra trial start gave no confirmation dialog, no stated end date, and no immediate record in the billing Your products view. P2 and the Governance add-on both surfaced their dates at activation. This one did not. The record was eventually found through Billing, Licenses: Microsoft Entra Workload ID, subscription dated Jul 26 2026, 200 purchased, 0 assigned. No end date surfaced anywhere in the portal, so the tracker entry is the activation date with the standard 90 day trial assumption, to be verified before the August cancellation sweep. Activation timestamp logged the moment the gap was noticed, because an untracked clock is the exact failure mode the licensing discipline exists to prevent. Three trials now tracked: P2 renews 8/10, Governance add-on 8/18, Workload ID activated 7/26.

## Finding: Workload identity licensing is capacity, not assignment

0 of 200 assigned, and CA08 works anyway. P2 required assigning licenses to individual users before Identity Protection covered them. Service principals do not take license assignments that way, the entitlement is tenant-level capacity priced per workload identity. That is also the cost-efficiency answer for this lab: a company pays per automation identity protected, which is why the Lab 1 inventory comes first, it is what makes the licensing quantity a measured number and the spend decision rational.

## Mistake: Principle, Principal, and a name that drifted

The policy went in as CA08-Block-Service-Principle-Outside-US. Two problems. Principle is the wrong word, the security identity is a principal, and the misspelling sat in the one repo whose purpose is demonstrating identity fluency. And the name had drifted from the one actually chosen, CA08-Block-Automation-OutsideUS, into the class-based alternative that was considered and set aside. Renamed to CA08-Block-Service-Principal-Outside-US before the evidence captures, settling on the class-based name deliberately this time, with the note that tonight it covers exactly one service principal and widening the scope later is a real change, not a rename. Same plain-documentation treatment as the Active and Eligible slips in Phase 06. Naming discipline in security objects is a real thing.

## Decision: Report-only first, then enforce, and CA07 stays parked

**Context:** CA08 blocks the 52Logistics-Automation service principal outside the Phase 04 US named location. The include-any, exclude-trusted-location shape is CA03 applied to a workload identity.

**Decision:** Built in Report-only per the discipline that has held since CA01. Validation: ran the inventory script under app-only auth, then confirmed in the Service principal sign-ins log that CA08 evaluated with Result Report-only: Not applied, the correct verdict for a sign-in from inside the excluded location. A true foreign-IP negative test is not reachable from this environment, same documented constraint as CA03 in Phase 04.

Then enforced. The reasoning: the policy logic is identical to CA03, which has run enforced since Phase 04 without touching legitimate traffic. The threat is concrete, a stolen certificate private key currently works from anywhere on earth, and enforcement converts a global compromise into a location-constrained one. And the argument for more Report-only time fails on inspection here, because the entire environment is one machine in one location, so waiting generates more of the same single data point, not broader validation. The blast radius of a wrong block is one manually-run script, noticed immediately.

CA07 stays in Report-only deliberately, for the opposite reason: session hardening controls degrade user experience and the evidence for tuning them never fully materialized. Two Report-only policies existed tonight, one graduated, one stays parked, each with a stated reason.

One structural note: every user policy since CA01 excluded the break-glass group. Workload identity policies scope to service principals, so no break-glass concept exists to exclude, and the equivalent failure mode, blocking your only automation identity everywhere, is what the Report-only-first discipline covers for this policy type.

---

# The Thread of the Night: One App, Two Objects

The registration and service principal split surfaced five separate times, and each time it explained something that otherwise looked wrong. The App registrations blade sat empty while Enterprise applications held over two hundred entries, because consented third-party apps only project service principals into the tenant. Registering 52Logistics-Automation created its service principal automatically, one app existing in both blades at once. The automation certificate was invisible to the inventory because it lives on the application object and the script reads service principals. The ownership fix had to be applied twice, once per object, because each keeps its own owner list. And the SAML signing certificate showed up on FreightPortal's service principal as both a secret and certificate entry, platform-generated credentials the admin never explicitly created, caught by the audit because SAML signing keys land on the service principal side.

That last one is worth its own line: the final inventory run showed FreightPortal carrying a secret and two certificates, all expiring 7/26/2029, none of which I created directly. Entra wrote the SAML signing key to both credential collections on the service principal. An inventory that catches platform-generated credentials the admin never made is doing precisely the job it was built for.

---

# The Inventory as a Recurring Control

Four runs in one night, and the numbers tracked real tenant change: 212 service principals before the phase, 216 after Lab 2's consent grant and Lab 3's registration materialized Graph Explorer and the automation app, 218 by the final run with FreightPortal and its service principal in place. The ownerless list turned over across runs, the automation app dropped off after the ownership fix and FreightPortal joined because it never got one, a finding remediated and a new one surfaced by the same tool in the same night. FreightPortal's ownership fix goes on the punch list.

One script bug for the record: the final run printed the carrying-credentials count blank where it should have shown 1. The detail table below it was correct. Output formatting fix, toolkit backlog.

---

# Carryover

The parameterized CA policy template script owed to PowerShell-Toolkit since Phase 04 remains outstanding. CA08 was built in the portal, so the optional payment window this phase might have opened did not trigger. The debt rides to the post-phase backlog where it has lived since Phase 04, alongside the two new toolkit items from this phase: the application-object credential pass and the count formatting fix.

FreightPortal owner assignment is the one open remediation from the final inventory run.

---

# Key Findings

- Delegated consent accumulates on shared service principals, and the union of every past grant rides into every new session.
- Admin consent is always a tenant-wide grant. The requesting user is the trigger, the tenant is the scope.
- Review and grant are separate powers in the consent workflow, enforced by role, usable as a real triage design.
- Application permissions can never be user-consentable, regardless of low-impact classification.
- Credentials and owners exist independently on the application object and the service principal, and an audit that reads one side misses the other.
- SAML signing certificates are platform-generated credentials that land on the service principal, in both credential collections.
- Conditional Access Success and sign-in Failure coexist on one log row, because CA and application assignment are independent gates.
- Workload identity licensing is tenant capacity, not per-identity assignment, which makes the inventory the input to the spend decision.
- Third-party test dependencies rot, and validating against one requires checking it is still what it was.
- The admin workstation is part of the attack surface the tenant hardening does not cover.