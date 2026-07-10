# Phase 04 Decisions - Conditional Access


## Decision: Sequence policy build before disabling Security Defaults

**Context:** Security Defaults and Conditional Access are mutually exclusive. Phase 01 found the tenant relying entirely on Security Defaults with no CA layer on top of it.
**Decision:** Build and validate replacement CA policies in Report-only before disabling Security Defaults, not after.
**Note:** Security Defaults was disabled once before this sequencing was fully worked out. Caught immediately, re-enabled Security Defaults, corrected the order going forward.

---

## Decision: Rely on Microsoft-managed policies as an interim safety net

**Context:** Attempting to re-enable Security Defaults during the sequencing mistake above, Entra blocked it, reporting that Conditional Access policies were already active in the tenant. Investigation showed Microsoft auto-deploys Microsoft-managed CA policies (Block legacy authentication, MFA for all users, MFA for admins, MFA for Azure Management) when Security Defaults is disabled without a custom CA policy present.
**Decision:** Confirmed this behavior against Microsoft Learn documentation. Accepted these Microsoft-managed policies as valid interim coverage rather than treating the gap as unprotected. Excluded own admin account from the Microsoft-managed MFA policy temporarily to avoid disruption while building custom replacements.

---

## Decision: Build role-differentiated policies instead of one blanket MFA policy

**Context:** Microsoft-managed policies apply the same MFA requirement to everyone, admins included. 52 Logistics has a small number of privileged accounts that warrant stronger controls than end users.
**Decision:** Built CA01, requiring the Phase 03 custom authentication strength (WHFB/Platform Credential or Password+Authenticator), scoped specifically to admin directory roles, layered on top of the baseline MFA all users already get.

---

## Decision: Add session controls for privileged roles

**Context:** No session-level controls existed for admin sign-ins, meaning an authenticated admin session could persist indefinitely.
**Decision:** Built CA02, sign-in frequency re-authentication plus non-persistent browser session, scoped to the same admin directory roles as CA01.

---

## Decision: Add a location-based policy reflecting actual business geography

**Context:** 52 Logistics operates as a single-region US company. No policy accounted for expected sign-in geography.
**Decision:** Built a US named location and CA03, blocking sign-in from outside it. Documented as a business-context decision, not a generic template control.

---

## Decision: Validate every policy in Report-only against both admin and non-admin accounts before enforcing

**Context:** Needed evidence that role-scoped policies were behaving correctly before flipping them to enforcement.
**Decision:** Generated sign-in activity from two non-admin test accounts and from the primary admin account. Confirmed CA01/CA02 showed Not applied for non-admins and Success for the admin account. Confirmed CA03 showed Not applied across all US-based test traffic, accepted as evidence of correct non-interference given no foreign sign-in was reachable in this environment.
