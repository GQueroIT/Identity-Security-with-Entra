# Phase 07 Decisions - Identity Governance

## Overview

Phase 06 deferred access reviews on purpose, since they belong to Identity Governance and not Privileged Access. This phase picks that up and builds out the rest of the governance domain: access reviews on the PIM roles and group from Phase 06, an entitlement management package that modernizes the manual onboarding process from Phase 02, and two Lifecycle Workflows that automate the joiner and leaver tasks documented back in that same phase. I scoped access reviews on the remaining department groups from Phase 02 out of this phase entirely, since it's the identical pattern already demonstrated against Tier 2 Support with nothing new to show. Same call I made with WHFB and FIDO2 hands-on testing in earlier phases, a deliberate scoping decision, not a gap.

---

## Licensing Discovery

Before building anything I activated the Microsoft Entra ID Governance Add-on trial on top of the existing P2 trial from Phase 05. It turned out this add-on doesn't provision its own separate license pool. It stacks directly on the P2 licenses already assigned to Gabriel Quero, Natalie Lopez, and Jordan Reed. That explains why the trial only activated once I actually reached a feature that needed it, the same staggered pattern anyone scoping SC-300 governance labs against a trial tenant is going to hit.

Worth being precise here since it created a real scheduling risk. The two trials run on different clocks. Entra ID P2 converts August 10, 2026, at 1 paid license. The Governance Add-on converts August 18, 2026, at 10 paid licenses. Two separate cancellation dates stacked on the same tenant, easy to track one and miss the other. I'm treating mid-August as my real cancellation deadline for both, well ahead of either conversion date.

One more constraint surfaced on the ID Governance dashboard: guest access governance is gated behind billing administrator permissions specifically, not just Global Administrator. The tile told me directly I didn't have permission to enable it and to contact my billing administrator, even signed in as Global Admin. Worth knowing for anyone else scoping a guest access package against a trial tenant, being the identity admin isn't enough for this one feature.

---

## Access Reviews for PIM Roles and a PIM-for-Groups Object

### Two different creation paths for the same governance concept

The generic path, ID Governance > Access reviews > New, only offers two review types: Teams + Groups and Applications. There's no option for Microsoft Entra roles anywhere in that dropdown. Reviews of directory role assignments get created from inside Privileged Identity Management itself, under Microsoft Entra roles > Access reviews, scoped to a specific role. That's not a bug, it's how Microsoft split the feature. Worth stating plainly since it's easy to assume access reviews live in one place.

The Tier 2 Support group review sits in a third position entirely. Because that group is role-assignable and managed through PIM for Groups, Entra recognized it the moment I selected it in the generic Access reviews wizard and told me directly the review would evaluate both eligible and active member assignments. So the same governance concept, reviewing continued access, spans three different creation surfaces depending on what's actually being reviewed: PIM's own blade for directory roles, the generic blade for a PIM-for-Groups object, and presumably the generic blade again for anything that isn't PIM-governed at all.

### Building the three reviews

**User Administrator, self-review.** Jordan attests to his own continued need for the role. Same reasoning I used for this role's activation settings in Phase 06, it's routine account work and doesn't need a second person checking Jordan's own attestation.

**Security Administrator, reviewer assigned to me.** Higher blast radius role, mirrors the approval gate I already put on this role's activation back in Phase 06. I hit a real trap building this one. The Reviewers dropdown defaults through several options, and I initially landed on "Manager" instead of "Selected user(s)." Manager routes the review to whatever's populated in the target user's Manager profile field, with a fallback reviewer required in case that field is empty, which is where my own name showed up as the fallback, not the primary reviewer. Corrected it to "Selected user(s) or group(s)" with myself explicitly added. Worth documenting since it's a genuinely easy setting to get wrong, and it would have quietly routed a sensitive role's review through an unrelated profile field if I hadn't caught it.

**Tier 2 Support, self-review.** Same routine-work reasoning as User Administrator, since this group bundles the same tier of access.

All three set to Quarterly frequency, End: Never, Auto-apply results: Enable, If reviewers don't respond: Remove access. Same enforcement philosophy running through the whole project since Phase 01, standing access doesn't get to sit unreviewed.

### The placeholder end date, resolved

Early on the End date field showed inconsistent-looking values, 07/19/2039 on one review, 10/20/2026 on another, both with End set to Never. Turned out that field is a disabled placeholder Microsoft populates inconsistently when Never is selected, it isn't a real saved value. The actual confirmation that Never saved correctly showed up later on the PIM Access reviews list, where the series End Date column read 12/31/9999, Microsoft's real internal representation of no end date. The 8/13/2026-style dates I saw when drilling into an individual review instance are due dates for that specific response window, not the series end date. Two different fields that look similar and aren't.

Also worth noting, Duration auto-scaled from 5 days under Weekly frequency to 25 days once I switched to Quarterly. That's Microsoft's default review window scaling with recurrence, not something I tuned by hand, and 25 days is a reasonable window for a review that only comes around four times a year.

### An expired eligibility window and a mistake I almost made

When I went to run the Tier 2 Support review, Jordan wasn't showing up in the group at all. Traced it back to Phase 06, I'd deliberately used a short same-night eligibility window for his PIM-for-Groups assignment, and it had expired by the time this phase started. My first instinct was adding Jordan directly as a standing member of the group, since I figured I'd be re-adding him repeatedly through PIM anyway. Caught myself before doing it. A direct member add would have given Jordan permanent User Administrator and Authentication Administrator with no MFA, no justification, no ticket requirement, the exact standing-access problem this whole project has been arguing against since the Phase 01 finding on three permanent Global Admins.

The actual fix was re-adding Jordan through PIM eligibility with the full one-year duration cap, not a same-night window. Worth stating plainly, a short eligibility window chosen for expedience in one phase created real operational friction in the next one, and the fix is a longer window, not standing access.

### PIM for Groups requires an active session before self-review is reachable

Once Jordan's eligibility was fixed, his Tier 2 Support review still wasn't reachable from myaccess.microsoft.com's self-service response screen until he actually activated his PIM-for-Groups membership first. Confirmed this directly, an eligible-only member can't respond to that group's access review at all, the response screen simply isn't available without a live session. This is meaningfully different from the two Microsoft Entra role reviews, where Jordan could respond to the User Administrator review with no activation required. Same underlying access review mechanism, two different behaviors depending on whether the resource being reviewed is a directory role or a PIM-for-Groups object. Self-review on a PIM-governed group forces the reviewer to actually exercise the access they're attesting to, there's no passive attestation path available.

### Closing the loop

All three reviews were answered with real decisions, not left sitting configured and unused. Jordan approved his own continued need for User Administrator and, after activating, for Tier 2 Support. I approved Jordan's continued eligibility for Security Administrator with a comment. Confirmed afterward in PIM Assignments that all of Jordan's role and group eligibility remained intact post-review, exactly the expected outcome for an Approve decision. Approve outcomes don't produce a visible before-and-after change, the real evidence auto-apply is working correctly is the configuration itself, Enable with Remove access as the fallback, not a diff that only shows up on a Remove decision.

---

## Entitlement Management for IT Onboarding

### Catalog and resource structure

Built a catalog called 52 Logistics Onboarding before touching a package, and added the IT security group as a resource inside it. This is the piece that makes the design scale past today, every future department's onboarding package lives in the same catalog. Adding department two, three, and four later means creating another package inside the existing structure, not rebuilding anything.

### The access package, and a configuration mistake worth stating plainly

Built IT New Hire Access, tied directly to the Christopher Young onboarding scenario from Phase 02, right down to reusing Sofia Martinez as the hiring manager on the test request. Resource role grants Member on the IT group. Custom questions capture Start Hire Date and Hiring Manager Name, so the request carries real business context, not a rubber stamp click.

I initially left the Requests tab configured with only Admin checked under "Who can request access," Self unchecked. Admin can't be turned off since admins can always assign directly, but with Self unchecked there was no self-service request path at all, defeating the entire point of the lab. Caught it before creating the package and checked Self. Worth naming plainly, easy to miss a single checkbox on a tab with a dozen other settings, and it would have quietly reduced the whole scenario to admin-only assignment.

Scope is set to "For users, service principals, and agent identities in your directory" with "All members (excluding guests)." That's broader than a tightly scoped requestor group, technically anyone in the tenant could request IT access right now, not just someone flagged by HR. Real tradeoff worth naming honestly. It isn't tightly scoped, and I'm not pretending otherwise. At 52 Logistics' current size this is a reasonable starting point, most organizations start exactly here and tighten scope once request volume actually justifies a dedicated requestor group.

Approval requires justification, single stage, with myself as First Approver. Lifecycle set to 365-day expiration with quarterly access reviews attached to the package itself, reviewer set to me, Remove access on no response. Same governance pattern from the access reviews above, applied here to package membership instead of role eligibility. Worth calling that consistency out directly, the quarterly-review-with-auto-apply standard isn't a one-off, it's the baseline I'm holding every kind of access to in this tenant.

### Requesting and approving

Jordan submitted the request through myaccess.microsoft.com, answering both custom questions and providing a business justification. The request sat at Pending approval for a noticeable stretch before it became actionable from the approver side, entitlement management requests route through a backend provisioning step before an approval action is even available, unlike PIM activation requests in Phase 06 which showed up for action almost immediately. Worth building in a few minutes of buffer for this specific workflow rather than assuming something's broken.

I approved the request through myaccess.microsoft.com's Approvals screen, which turned out to be considerably faster to find and use than digging through the admin center's package-specific Requests blade. Worth naming as its own usability finding, this self-service portal is clearly the intended path for both requesting and approving, not the admin center.

One detail worth documenting on its own: the request carried a due date of August 2, 2026, exactly 14 days after submission. That's Microsoft's default entitlement management decision window, not something I configured, and it functions as its own governance mechanism, a structural parallel to "If reviewers don't respond, Remove access" from the access reviews. Nothing in this phase sits in limbo indefinitely, every governed process has a default outcome if a human doesn't act on it.

Confirmed the full chain worked end to end. The admin center Requests screen showed Status: Delivered, distinct from Approved, Approved is the human decision, Delivered is the system confirming the provisioning itself completed. Checked Groups > IT-Group > Members directly and found Jordan Reed sitting there as a direct member, next to Sofia Martinez, proof the request-to-approval-to-delivery chain actually produced the real access it claimed to.

---

## Lifecycle Workflows for Onboarding and Offboarding

### On-demand execution is not a trigger type

Every Lifecycle Workflows template forces a selection under Trigger details at creation time, and the only options are Time based attribute, Attribute changes, and Group membership changes. There's no on-demand choice anywhere in that list. On-demand execution turns out to be a separate capability that lives on the workflow's own page after creation, not a trigger configured up front. Left Time based attribute as the default at creation since it's required to get through the wizard, then used the dedicated Run on demand control from the Workflows list for every actual test run.

Before running anything for real, I used the What-if feature, checked at creation, which simulates the scope rule against real tenant users without executing a single task. Worth stating the distinction plainly, What-if validates who the rule would catch, on-demand execution actually runs the tasks. Two separate safety nets, and using the first one before committing to the second is a practice worth keeping going forward.

### Onboarding: a real troubleshooting arc across four runs

Built "Onboard new hire employee," scoped to department equal IT, with four tasks: Enable User Account, Send Welcome email, Add user to groups, Generate TAP and Send Email. Caught and removed an accidental duplicate Send Welcome email task before creating the workflow, worth a quick note since it's easy to leave a stray task in place moving through a multi-tab wizard quickly.

**Run 1, 5:03 PM. Failed, 1 of 4.** Send Welcome email failed with "manager email address is missing or invalid." Add user to groups and Generate TAP and Send Email both showed Canceled, not Failed. That's a real architecture detail worth naming directly, Lifecycle Workflows runs its tasks sequentially, and one failure cancels everything downstream regardless of whether the later tasks have anything to do with the one that failed. Add user to groups had no dependency on manager email at all and still never ran, purely because it was queued behind the broken task.

**Run 2, 5:08 PM. Failed, 1 of 4.** Fixed the manager email gap on Daniel Kim's profile. Welcome email now completed. Add user to groups completed too, with processing info reading "User already a member of requested group," an idempotency success, not a false failure, matching the same pattern Enable User Account showed on Run 1 with "User account already enabled." Generate TAP and Send Email failed this time on "EmployeeHireDate attribute is missing."

**Run 3, 5:17 PM.** Same failure, same missing attribute, confirming it was a real unfixed gap and not a one-time fluke. Worth noting the platform labeled this run's status "Completed with errors" rather than Failed, a distinct status from Run 2's outright Failed despite an identical single-task failure. Worth a line on why that label changed between two functionally equivalent runs.

**Run 4, 5:24 PM. Completed, 0 of 4 failed.** Backfilled employeeHireDate on Daniel Kim's profile and reran. Full clean pass.

This traces back directly to a warning already sitting in user-properties.md from Phase 02, that letting a profile go stale quietly breaks Identity Governance and access reviews downstream. This is that warning proven concretely, three phases later, against a real Microsoft Entra Governance feature. Worth being direct about the actual root cause too, this wasn't a Lifecycle Workflows defect, it was incomplete test-persona data from account creation that nobody backfilled until a governance workflow depended on it. Also worth noting, this is the second time this project has hit an async processing gap between triggering an action and the platform actually completing it, once with P2 licensing and Identity Protection in Phase 05, now with a workflow run sitting In Progress for several minutes before its status resolved. Worth treating as a recurring pattern in this tenant, not two disconnected incidents.

### Offboarding: a different kind of finding entirely

Built "Offboard an employee," same department eq IT scope, four tasks: Disable User Account, Remove user from all groups, Remove user from all Teams, Remove all licenses for user.

Applied the lesson from onboarding directly this time. Checked Maya Chen's profile for a valid manager email before running anything, rather than walking into the same wall a second time for no reason.

The run completed with 3 of 4 tasks succeeding. Disable User Account, Remove user from all groups, and Remove user from all Teams all completed cleanly. Remove all licenses for user failed, with a specific and informative error: "User license is inherited from a group membership and it cannot be removed directly from the user." That's not a data gap, it's a real structural interaction with a group-based licensing assignment I'd set up on the IT group before starting this lab.

Checked Maya Chen's account directly afterward in the Microsoft 365 admin center. She showed Unlicensed, sign-in blocked, and no group memberships. The license was already gone, removed as a side effect of task 2 pulling her out of the licensed group, two tasks before the license removal task even ran. The failure wasn't a gap in the workflow at all. It was a task with nothing left to do by the time it executed, because an earlier task already accomplished the same outcome through a different mechanism.

This is a genuinely stronger finding than the onboarding one, and it's worth explaining why. Onboarding showed that missing data breaks task execution. Offboarding showed that task ordering and licensing architecture interact in a way that makes an explicit license-removal step redundant by design once group-based licensing is in play. That's a real argument for a specific licensing model, not just a workaround, group-based licensing turns offboarding into a built-in safety net. Pull someone out of the group and the license goes with them automatically, no separate cleanup step required, no risk of a disabled account quietly sitting on a paid license because someone forgot a step.

---

## Enhancement: Group-Based Licensing as a Tenant-Wide Model

The offboarding finding directly informs a real decision I want to make about how 52 Logistics licenses users going forward. Right now licensing at 52 Logistics is a mix of direct per-user assignment and the one group-based assignment I set up on the IT group for this lab. Moving licensing to group-based assignment tenant-wide, tied to the same department security groups built in Phase 02, would turn every offboarding action into the kind of safety net this lab just demonstrated by accident. Pull someone from their department group during offboarding and their license goes with them, no separate license-removal step needed at all.

I'm scoping the actual implementation of this out of Phase 07 on purpose. Building it properly means extending Create-52Logistics-DepartmentGroups.ps1 from Phase 02 to also handle group-based license assignment, testing it against multiple department groups, and likely revisiting the Lifecycle Workflows task list to drop the now-redundant Remove all licenses for user step entirely once every department is licensed this way. That's real, separate work, not a quick addition to a phase that's already covered three distinct governance mechanisms. Same call I made with WHFB and FIDO2 hands-on testing in earlier phases and with the Phase 04 CA policy template script still outstanding, a deliberate scoping decision with a clear reason stated, planned for after the core twelve phases close out, not left as an unexplained gap.

---

## Key Findings

- Access review creation splits across three surfaces depending on what's being reviewed: PIM's own blade for directory roles, the generic Access reviews blade for a PIM-for-Groups object, and presumably the same generic blade for anything not PIM-governed at all.
- The Reviewers dropdown's "Manager" option routes to a user's profile Manager field with a required fallback reviewer, an easy trap to fall into when "Selected user(s)" is what's actually needed.
- A review's series End Date, shown as 12/31/9999 when set to Never, is a different field from an individual instance's response due date, and the two can look inconsistent without actually being wrong.
- A short PIM eligibility window chosen for one phase's convenience created real friction in the next phase, and the fix is a longer eligibility window, not a standing membership assignment.
- Self-review on a PIM-for-Groups object requires an active session before the response screen is even reachable, unlike self-review on a Microsoft Entra role, which needs no activation.
- Entitlement management requests route through a backend provisioning delay before becoming actionable to an approver, and myaccess.microsoft.com is meaningfully faster to work from than the admin center for both requesting and approving.
- Entitlement management assignments carry a default 14-day decision window if left unconfigured, functioning as its own governance safety net.
- Lifecycle Workflows tasks execute sequentially, and one task's failure cancels every downstream task regardless of whether that task depended on the one that failed.
- Incomplete test-persona data, specifically missing manager email and missing employeeHireDate, directly breaks Lifecycle Workflows task execution, confirming a warning already documented in Phase 02's user-properties.md.
- Group-based licensing makes an explicit "remove all licenses" offboarding task redundant, since removing group membership already revokes the inherited license as a side effect, a real argument for adopting group-based licensing tenant-wide.
- This is the second time the project has hit an async backend processing delay between triggering an action and the platform completing it, first with Phase 05 P2 licensing propagation, now with Lifecycle Workflows run status.