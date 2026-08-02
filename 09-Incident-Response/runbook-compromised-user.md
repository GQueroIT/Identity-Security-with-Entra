# Runbook: Compromised User Account

Response procedure for a suspected or confirmed compromise of a 52 Logistics user account. Covers cloud identity only. Does not cover workload identities or endpoint compromise.

This procedure is derived from the July 2026 incident on Natalie Lopez's account, documented in Investigation-Remediation-NatalieLopez.md. That response worked because the responder was also the tenant administrator who built the environment. This runbook exists so the response no longer depends on that person being at the keyboard.

## Trigger Conditions

Start this runbook when any of the following occur:

- User risk level reaches High in Identity Protection
- A risk detection fires for anonymous IP address or impossible travel
- An administrator confirms compromise from external evidence
- A user reports account activity they did not perform

Medium user risk alone does not trigger this runbook. Monitor and reassess within 24 hours.

## Prerequisites

- PIM eligibility for Security Administrator (approval required, reference the incident in the justification)
- PIM eligibility for the Tier 2 Support group (grants User Administrator and Authentication Administrator)
- Access to the Microsoft Entra admin center
- Contain-CompromisedUser.ps1 from PowerShell-Toolkit (optional, Stage 3 can run fully manual)

## Escalation

If PIM activation fails, or the compromised account holds any privileged role, stop immediately and contact the Global Administrator directly. Do not attempt containment on a privileged account with Tier 2 roles. Any break-glass account sign-in observed during this procedure is a separate incident by definition.

---

# Stage 1: Detect

1. Open Entra admin center, go to Protection, Identity Protection, Risky users. Verification: the affected user appears in the list with a risk level.

2. Record the user, risk level, and risk last updated timestamp. Verification: all three values written into the incident timeline before any action is taken.

3. Check the risk level against the trigger conditions. Decision point: High risk or admin confirmation, proceed to Stage 2. Medium risk with no other trigger, monitor and reassess within 24 hours, do not proceed.

---

# Stage 2: Investigate

1. Activate Security Administrator through PIM. Approval is required. Verification: role shows Active under My roles.

2. In Risky users, select the affected user and open the Risk detections tab. Record each detection type, timestamp, IP address, and location. Verification: every detection in the suspect window is in the timeline.

3. Open Sign-in logs and filter to the affected user, window starting 24 hours before the first detection. Record IP, location, client app, and Conditional Access result for each sign-in in the window. Verification: suspect sign-ins are identified and distinguishable from the user's normal pattern.

4. Open Audit logs and filter to the affected user for the same window. Look specifically for authentication method changes, consent grants, and property changes. Verification: any change made during the suspect window is recorded in the timeline.

5. Contact the user through a known good channel, not through the affected account. Ask whether they performed the flagged activity. Verification: user's answer recorded with timestamp.

6. Decision point, judged on the evidence above:
   - Proceed to Stage 3 if any of the following: successful sign-in from an anonymized or unexplained IP, the user denies the activity, authentication methods or consents changed without the user's knowledge.
   - Stand down as false positive only if all of the following: the activity has a confirmed benign explanation (travel, VPN), the user confirms every flagged sign-in, and no directory changes occurred in the window. Dismiss the risk in Identity Protection and document the false positive in Stage 6. Do not dismiss risk to clear a dashboard.

---

# Stage 3: Contain

Perform these steps in order. The order stops new sessions from starting before existing sessions are killed.

1. Activate the Tier 2 Support group through PIM if not already active. Verification: User Administrator and Authentication Administrator both show Active.

2. In Users, select the affected user, edit properties, set Account enabled to No, save. Verification: user profile shows Sign-in blocked: Yes.

3. On the same user profile, select Revoke sessions and confirm. Verification: the revoke event appears in the audit log.

4. In Identity Protection, Risky users, select the user and select Confirm user compromised. Verification: risk state shows Confirmed compromised, risk level High.

Script alternative: steps 2 through 4 run as one call with Contain-CompromisedUser.ps1. The PIM activations in step 1 and Stage 2 step 1 are still required first.

---

# Stage 4: Remediate

1. Reset the user's password from the user profile, using a strong temporary password with change at next sign-in required. Verification: reset event appears in the audit log.

2. Review the user's registered authentication methods. Remove any method added during the suspect window. Verification: only methods the user confirms as theirs remain.

3. Revoke any application consents granted during the suspect window, identified in Stage 2 step 4. Verification: the grants no longer appear on the user's applications.

4. Check the user's risk state in Identity Protection after remediation. If risk remains, dismiss it now that remediation is confirmed complete. Verification: user no longer appears in the Risky users list.

---

# Stage 5: Recover

1. Re-enable the account: user profile, edit properties, Account enabled to Yes, save. Verification: Sign-in blocked shows No.

2. Deliver the temporary password to the user through the known good channel from Stage 2. Verification: user confirms receipt.

3. Have the user sign in, change the password, and complete MFA. Verification: sign-in log shows a successful sign-in with MFA satisfied and normal Conditional Access evaluation.

4. Confirm no new risk detections fired on the recovery sign-in. Verification: user absent from Risky users, no new detections.

Recovery is complete when the clean sign-in is proven, not when the account is re-enabled.

---

# Stage 6: Document

1. Complete the incident report using Investigation-Remediation-NatalieLopez.md as the template: timeline, actions taken, evidence, findings.

2. Deactivate all PIM roles activated during the response. Verification: no roles show Active under My roles.

3. File the report in 09-Incident-Response. Verification: report committed.

---

# Role Reference

| Stage | Minimum role | How the responder gets it |
|---|---|---|
| Detect | Security Reader (view) | Standing, or Security Administrator activation |
| Investigate | Security Administrator | PIM activation, approval required |
| Contain | User Administrator + Security Administrator | Tier 2 Support group activation + Security Administrator activation |
| Remediate | User Administrator, Authentication Administrator, Security Administrator | Tier 2 Support group + Security Administrator, already active |
| Recover | User Administrator | Tier 2 Support group, already active |
| Document | None | Not applicable |