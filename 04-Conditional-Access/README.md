# Conditional Access

I inherited a tenant that was leaning entirely on Microsoft Security Defaults for MFA enforcement. No Conditional Access layer existed on top of it, no differentiated policy for admins versus regular users, no session controls, and no way to build in business context like expected sign-in locations. That gap came directly out of my Phase 01 assessment, and this phase is where I closed it.

---

## Conditional Access Architecture

<p align="center">
  <img src="./diagrams/conditional-access-diagram.png" alt="52 Logistics Conditional Access Architecture" width="100%">
</p>

<p align="center">
  <i>Figure 1. Conditional Access architecture, policy inventory, validation process, and enforcement model for the 52 Logistics Microsoft Entra tenant.</i>
</p>

---

## The Sequencing Problem

Security Defaults and Conditional Access can't run at the same time. Microsoft requires Security Defaults to be disabled before any CA policy can be enforced, and the reverse is also true, existing CA policies have to be cleared before Security Defaults can be re-enabled.

I ran into this the hard way. I disabled Security Defaults before my replacement policy existed, which meant the tenant briefly sat without an active MFA enforcement layer. I caught it, went to re-enable Security Defaults right away, and Entra wouldn't let me, it detected Conditional Access policies already active in the tenant. I hadn't built any yet, which led to the finding below. From there I corrected the sequencing for good: build and validate the policy in Report-only first, then disable Security Defaults, then enforce.

----

## An Unexpected Safety Net

When Entra blocked my attempt to re-enable Security Defaults, it turned out Microsoft auto-deploys a set of Microsoft-managed Conditional Access policies the moment Security Defaults is disabled without a custom CA policy in place: Block legacy authentication, MFA for all users, MFA for admins, and MFA for Azure Management. These aren't something an admin builds, Microsoft creates and maintains them directly as a transitional safety net so a tenant isn't left exposed.

That meant the tenant was never actually unprotected during my sequencing mistake, Microsoft's own policies stepped in automatically. I confirmed this behavior against Microsoft Learn documentation before treating it as fact, and I excluded my own admin account from the Microsoft-managed "MFA for all users" policy temporarily so it wouldn't interrupt testing while I built the custom policies meant to replace it.

----

## Policies Built

I scoped three custom Conditional Access policies to what actually fits a company 52 Logistics's size, a single-region logistics operation with a small number of privileged accounts, not a sprawling enterprise.

**CA01, Require phishing-resistant authentication for admin roles.** Targets directory roles like Global Administrator and Privileged Role Administrator, and requires the custom authentication strength built back in Phase 03, Windows Hello for Business or Platform Credential, or Password plus Authenticator. Regular users still get standard MFA through the Microsoft-managed policy, admins get held to a higher bar. Break-Glass Group is excluded from every policy in this phase.

**CA02, Admin session controls.** Requires re-authentication for privileged roles on a set interval instead of letting an admin session sit open indefinitely, plus a non-persistent browser session so closing the browser actually ends things.

**CA03, Block sign-in from unexpected locations.** 52 Logistics operates entirely within the US, so I built a named location for the US and blocked sign-ins falling outside it. This one reflects actual business geography for this specific company, not a generic template control.

---

## Validation

Everything ran in Report-only first, tested against real sign-in activity. Signing in as two regular test users showed CA01 and CA02 as Not applied, correctly, since neither user holds an admin role the policies target. Signing in as my own admin account showed both as Report-only Success. That contrast, Not applied for a non-admin, Success for an admin, on the same policy, is the clearest evidence that the role scoping works as intended.

CA03 showed Not applied across every test sign-in, all of which came from within the US. That's the correct result given the policy fires on sign-ins outside the US, and I'm treating it as evidence the policy isn't false-triggering on legitimate traffic, since generating an actual foreign sign-in wasn't reachable in this environment.

---

## Going Live

With that evidence in hand, I disabled Security Defaults for real, this time with CA01 through CA03 already built and validated, and turned all three policies on. The tenant now enforces phishing-resistant auth for admins, session controls for privileged roles, and geo-based blocking, sitting on top of the baseline Microsoft-managed policies covering everyone else.

---

## One More Finding Along the Way

While verifying things in tenant properties, I noticed my own account carrying a permanent User Access Administrator role assignment at Azure Root scope, left over from an earlier elevated access action. Nothing in this project touches Azure resource management, it's Entra ID identity work end to end, so that was standing access with no reason to exist. I removed it. Same principle as everything else in this phase: privileged access doesn't get to sit around just because nobody happened to look at it.