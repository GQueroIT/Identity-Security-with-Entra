# Phase 06: Privileged Access

## Overview

This phase covers Privileged Identity Management for 52 Logistics LLC. I built three scenarios, each one tied to a different level of role sensitivity, so the PIM configuration itself would have to change to match the risk. I didn't want to just flip PIM on for one role and call it done. I wanted to show I understand when self-activation is enough, when a role needs a second person approving it, and when multiple roles need to be bundled behind a single activation because a task genuinely can't be finished with just one of them.

Access reviews are part of Identity Governance, so I kept them out of this phase and I'm pushing them to Phase 07 where they belong.

---

## Setup

I assigned Jordan Reed as Eligible for both User Administrator and Security Administrator, permanently eligible in both cases. I made that call because I didn't want the eligibility window itself to be the thing that expires mid-project. Activation duration is where the real time boundary belongs, not eligibility.

Role settings for User Administrator: 4 hour activation max, MFA required, justification required, ticket number required, no approval needed. This role handles routine account tasks, so requiring a second person to approve every activation would slow down exactly the kind of work User Administrator exists for.

Role settings for Security Administrator: 2 hour activation max, same MFA, justification, and ticket requirements, but with approval turned on and myself listed as the approver. Security Administrator touches identity protection and risk configuration, which has a bigger blast radius than account provisioning, so I wanted a human checkpoint before that role goes active.

I hit two real mistakes setting this up that are worth stating plainly. First, I initially selected Active instead of Eligible on the assignment type, which would have handed Jordan the role standing instead of letting Jordan request it. Second, I scheduled the assignment start time for a future date and time instead of the current moment, which meant the eligible assignment existed but wasn't live yet, and PIM showed it as a pending scheduled action instead of something Jordan could act on immediately. Both mistakes trace back to the same root cause: the assignment configuration and the role's activation rules are two separate layers, and it's easy to set one correctly while getting the other wrong. I caught both before running any scenario, but I'm noting them because the same mistake showed up a third time later in the group assignment for scenario 3. That's a pattern, not a one-off typo, and worth watching for in future phases.

---

## Scenario 1: Self-Activation for Routine Account Provisioning

Jordan self-activated User Administrator, tied to a fictional ticket for account provisioning. The activation required MFA, a justification statement, and a ticket number, all of which were enforced by the role settings and had to be filled in before the activation would go through. MFA fired during activation and was satisfied in real time. I didn't get a screenshot of the actual MFA challenge screen because it moved too fast to capture, but the requirement was live and functioning, confirmed by the fact that the activation form wouldn't submit without it.

Once active, I used the role to create a test user account, tying the elevated permission to an actual task instead of just the activation existing in isolation. The activation completed successfully and showed up in the assignment's activity history as "Add member to role completed (PIM activation)."

This scenario shows the baseline PIM pattern: no approval needed, self-service, time-bound, and justified through required fields rather than a second person's sign-off.

---

## Scenario 2: Approval-Gated Activation for a Risk Investigation

Jordan requested activation of Security Administrator, tied to a fictional ticket for investigating a risk case. Because approval is required on this role, the request sat in a Pending state instead of going straight to Active. I want to be direct about something here: my first pass at checking this looked at the wrong screen and made it seem like approval hadn't fired at all, since the My roles view didn't show a pending state the way I expected. The actual pending request was sitting under Approve requests instead, a separate view scoped specifically to items awaiting action. Once I checked the correct screen, the request was there with the full detail set: requestor, role, ticket number, and justification, all attached and waiting on my approval.

I approved the request as Gabriel, with an approver comment, and Jordan's Security Administrator role went active immediately after. I used the elevated role to review Natalie Lopez's risk detection history in Identity Protection, which ties this activation back to real Phase 05 evidence instead of an arbitrary action.

The justification text I used for this activation was intentionally generic, since there wasn't an actual open investigation behind it. In a production environment this would need to tie to a real incident or case number. I'm stating that plainly rather than pretending the ticket represents something it doesn't.

I also want to note that email notifications for pending approvals weren't tested in this phase, since Outlook wasn't configured on this tenant. I verified the approval flow directly through the PIM portal instead of through an email link. I understand how the email-based approval path works, it just wasn't the path exercised here. This is a deliberate scoping decision, not a knowledge gap.

---

## Scenario 3: PIM for Groups, Bundled Roles for a Multi-Permission Ticket

This scenario is built around a fictional FIDO2 rollout at 52 Logistics, where users who get new security keys sometimes end up locked out with a stripped MFA method at the same time. Resolving a ticket like that requires two roles at once: User Administrator to unlock the account, and Authentication Administrator to reset or register the new authentication method. Neither role finishes the ticket alone, which is the whole reason to bundle them behind one activation instead of just scoping a policy to a group the way I would with Conditional Access.

I created a role-assignable security group called Tier 2 Support. Role-assignable has to be set at creation time and can't be added to an existing group afterward, and membership has to be Assigned rather than Dynamic. I assigned the group as Active and Permanent on both User Administrator and Authentication Administrator, since the group itself needs to hold the roles permanently for PIM-on-the-group to function. I then brought the group into PIM and added Jordan as an eligible member.

I hit the same Active-versus-Eligible mistake here that I made during the role setup earlier in this phase, initially assigning Jordan as an Active member instead of Eligible. I caught it by checking the audit history for the group, which showed a "Reason" field populated on an assignment, the same tell that had shown up during the earlier mistake, since that field only appears when you're directly granting Active membership rather than eligibility. I corrected it to Eligible.

One real difference worth noting between PIM for roles and PIM for Groups: role eligibility assignments support a Permanently eligible checkbox, but the group eligibility assignment screen capped out at a fixed start and end date instead, with a maximum allowed eligible duration of one year rather than an option for permanent. I used a short window since I was running the scenario the same night, but this is a genuine mechanical difference between the two PIM surfaces, not an oversight on my part.

Jordan activated the group, which required MFA, justification, and a ticket number, no approval, consistent with the reasoning that bundled routine support tasks shouldn't need a second person's sign-off any more than User Administrator alone does. I performed the account unlock as the User Administrator half of the task.

I attempted to register a FIDO2 security key for the test user as the Authentication Administrator half of the task, but FIDO2 Security Key wasn't available as an option in this tenant's authentication methods picker, most likely a limitation of the developer trial tenant. I chose not to substitute a different authentication method, since the point of this half of the scenario was specifically to validate FIDO2 registration under an elevated role, and swapping in an unrelated method wouldn't have tested that. The role's activation and permission grant were still fully exercised regardless of whether the underlying user action could be completed. This follows the same approach as the WHFB and FIDO2 deferral documented in Phase 05, a scoping decision made explicit rather than a gap left unexplained.

---

## Key Findings

- The Active-versus-Eligible assignment type is the single easiest setting to get wrong in the PIM interface, and I got it wrong three separate times across this phase, twice on direct role assignments and once on a group membership. The justification text box appearing is a reliable tell that Active was selected instead of Eligible, since that field only shows up when you're granting standing access rather than opening eligibility.
- A scheduled assignment start date in the future will show the eligible assignment as pending rather than immediately usable, and it won't appear under My roles until that start time passes. Worth double checking the start date and time every time, not just the assignment type.
- Approval-gated activation requests don't show up as Pending under a user's own My roles view in an obviously visible way. They need to be checked from the Approve requests screen on the approver's side to actually see the pending state and act on it.
- PIM for Groups and PIM for role assignments don't offer the same options for assignment duration. Role eligibility supports a Permanently eligible setting. Group eligibility caps at a fixed date range with a stated one year maximum.
- FIDO2 Security Key registration wasn't available in this tenant's authentication methods picker, consistent with a trial tenant limitation.