# Investigation and Remediation: Natalie Lopez Risk Detection

## Context

CA05 and CA06 needed real risk signals to validate against, so I generated two intentionally during Phase 05: an admin-confirmed user risk state through the Microsoft Graph riskyUsers API, and a sign-in risk detection from a Tor Browser sign-in. This doc walks through the investigation and remediation process I'd apply to any risky user, using this test case as the working example.

## Detection

- **Risky users report:** Natalie Lopez flagged High risk, risk detail tied to the admin-confirmed compromise action
- **Risk detections report:** Anonymous IP address detection, real-time timing, attack type Obfuscation/Access using proxy, IP geolocated to Cheyenne, Wyoming
- **CA05** evaluated the sign-in risk as Report-only Success on the Tor sign-in
- **CA06** evaluated the standing user risk as Report-only User action required on a later sign-in

## Investigation steps

1. Reviewed Natalie's risky sign-ins for anything outside the expected pattern, timestamps, application accessed, device and browser fingerprint.
2. Checked her sign-in logs for CA03 failures to rule out a broader access pattern beyond the one flagged sign-in.
3. Confirmed no app registrations, mailbox rule changes, or group membership changes were made under the account. Real compromised accounts often show lateral movement through one of these, and none were present here.
4. Traced both detections back to their source: the Graph confirmCompromised call and the Tor sign-in, both deliberate testing activity on my part, not unexplained behavior.

## Decision

Since these are test detections, I already know the ground truth. What matters for this doc is applying the same decision framework I'd use on a real account: self-remediation through the risk-based Conditional Access grant control comes first, manual admin remediation, password reset and session revocation, is the fallback if self-remediation doesn't happen.

I'm holding Natalie's risk state open for a few days to mirror how a real security team would treat a flagged account: sustained scrutiny and constrained access through a monitoring window, not an automatic all-clear the moment MFA and a password change complete. I'll watch for a return to normal sign-in patterns before dismissing the risk and marking the account safe.

## Current status

- Natalie Lopez: user risk High, risk state open
- CA06 (User risk, Require password change): On, will challenge her next sign-in
- Monitoring window: open, watching for normal login patterns before remediation

---

## Planned hardening: CA07

Password change and MFA close the immediate credential gap, but they don't do anything about what a session looked like on the way out. To show a fuller hardening pattern for an account under active risk, I'm building CA07, scoped to the same High user risk condition as CA06, but using session controls instead of grant controls: sign-in frequency set to require reauthentication every time, and persistent browser sessions disabled.

The idea is that CA06 handles the immediate credential response, and CA07 keeps any high-risk account on a short reauthentication leash for as long as that risk stays open, not just at the moment of the triggering sign-in. Two policies, two different jobs, both responding to the same signal.

## Next steps

- Continue monitoring Natalie's sign-in activity through the observation window
- Build and validate CA07 in Report-only
- Dismiss Natalie's risk state once the monitoring window closes clean
- Document the final remediation and close this case