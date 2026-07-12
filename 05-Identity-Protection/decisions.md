# Phase 05 Decisions

## Building risk policies in Conditional Access

Microsoft is retiring the legacy risk policy blades inside ID Protection on October 1, 2026, pushing organizations toward configuring User risk and Sign-in risk as conditions directly inside Conditional Access. Since this tenant's access window runs out before that retirement date, I built CA05 and CA06 the way a real organization would be expected to build them today, as Conditional Access policies rather than through the legacy User risk policy and Sign-in risk policy pages under ID Protection.

This also keeps the identity risk work consistent with everything from Phase 04. CA01 through CA04 already established Conditional Access as the single place this tenant enforces access decisions. Splitting risk-based controls off into a separate, soon-to-be-retired interface would have worked against that.

## Licensing scope for Entra ID P2

Identity Protection's risk detections and risk-based access controls require Entra ID P2, which this tenant did not have going into Phase 05. I activated the 30-day P2 trial and licensed three accounts: my own admin account, Natalie Lopez as a non-admin department user, and a dedicated test account, Jordan Reed.

I kept the license count at three on purpose. The trial offers up to 25 seats for free, but licensing every user in the tenant just because the seats were available would have worked against the least-privilege posture this whole project has been building toward since Phase 01. Three accounts cover every scenario Phase 05 and the upcoming PIM work in Phase 06 need, admin testing, a non-admin persona, and an isolated account for simulating risk so I never had to put my actual admin session at risk.

The P2 trial requires a credit card for identity verification, even though nothing is charged during the 30-day window. I set a reminder to cancel before August 2, 2026, well ahead of the August 10 conversion date, to avoid any chance of the subscription rolling into a paid tier.

---

## Two separate risk-based policies, not one combined policy

I built CA05 and CA06 as two independent policies instead of folding sign-in risk and user risk into a single policy with both conditions. Sign-in risk is evaluated in real time during authentication, while user risk is often calculated afterward through offline detection. A policy requiring both conditions to match at once would rarely fire, since the two signals are rarely present on the same sign-in at the same moment. Keeping them separate means each risk signal gets its own dedicated response.

**CA05 - SignInRisk - RequireMFA** targets Medium and High sign-in risk with a grant control of Require multifactor authentication.

**CA06 - UserRisk - RequirePasswordChange** targets High user risk only, with a grant control of Require password change. I kept this one to High only, since password change is a heavier control than MFA and I wanted the user risk response reserved for confirmed, high-confidence signals rather than triggering on Medium risk detections that carry more uncertainty.

Both policies were built and validated in Report-only before any enforcement decision, following the same validation pattern established in Phase 04.

## Generating test evidence

A fresh developer tenant has no sign-in history, so neither policy had anything real to evaluate against out of the gate. I used two different methods to generate test risk signals rather than waiting for organic detections that would likely never come before the tenant's access window closes.

For user risk, I used the Microsoft Graph riskyUsers confirmCompromised action to manually set Natalie Lopez's risk state to High. This is a documented Microsoft testing method, not a workaround, and it gave me an immediate, repeatable way to validate CA06 without waiting on any external detection pipeline.

For sign-in risk, I signed in as Natalie Lopez through Tor Browser. The anonymizing exit node tripped ID Protection's Anonymous IP address detection, which gave CA05 a real sign-in risk signal to evaluate.

---

## Real-world friction

A few things went sideways during this build, each worth documenting since they reflect genuine friction.

The first Graph script attempt failed twice, once because the user's Object ID wasn't quoted as a string in PowerShell, and once because the endpoint path was wrong. The riskyUsers actions live under `/identityProtection/riskyUsers/confirmCompromised` in the current API, not at the API root. Both were quick fixes once the actual error messages were read closely instead of assumed.

After licensing P2, the Graph call to confirmCompromised failed for a period of time with a tenant-not-licensed error, even though Conditional Access was already evaluating risk conditions successfully on the same tenant. This turned out to be a real quirk in how Microsoft's services onboard a new license, the risk evaluation engine behind Conditional Access came online faster than the separate identityProtection risk management API. The fix was simply waiting, not a configuration change, and it's worth noting for anyone hitting the same error after a fresh P2 activation.

During Tor sign-in testing, several attempts got blocked by CA03, the geo-block policy from Phase 04, since some Tor exit nodes geolocated outside the US. One attempt happened to route through a Cheyenne, Wyoming exit node and passed CA03 clean, but still tripped ID Protection's Anonymous IP address detection. That was a genuinely useful discovery: CA03 and CA05 aren't redundant. A location-based block only catches what looks foreign. A risk-based policy catches anonymization and proxy behavior even when the apparent location looks completely normal. That's the real argument for layering risk signals on top of geo-based rules rather than treating either one as sufficient on its own.

## Enforcement decision

CA06 (User risk, Require password change) is now enforced. The one validated trigger was a deliberate, unambiguous admin action through the Graph confirmCompromised call, not an inferred or automatic signal, so I was comfortable moving it straight to On.

CA05 (Sign-in risk, Require MFA) is staying in Report-only for now. This tenant has almost no sign-in history yet, and a Medium-and-High risk threshold on a tenant this young means normal testing activity could plausibly read as risky before there's enough baseline behavior established to trust the signal. I want more real sign-in volume behind it before I trust it to challenge live traffic. Same approach I used with CA04 in Phase 04, build and validate first, let it sit and observe before flipping to enforced.

## Natalie Lopez's risk state

I'm intentionally keeping Natalie Lopez's user risk state open rather than remediating it immediately after validation. A real security team wouldn't clear a flagged account the moment MFA and a password change complete, they'd watch it for a period of sustained scrutiny first. I'm holding her risk state open for a few days, watching for a return to normal sign-in patterns, before dismissing the risk and marking the account safe. Full investigation reasoning is in Investigation-Remediation-NatalieLopez.md.

## Natalie Lopez's risk state: resolved

I held Natalie Lopez's user risk state open for several days after validation instead of clearing it immediately, specifically to see whether CA06 would resolve the case on its own during a real sign-in rather than only during the original test trigger. It did. A later sign-in was challenged for a secure password change, she completed it, and her risk state moved to Remediated automatically. No manual admin dismissal was needed.

This is stronger evidence than the original validation alone. It shows CA06 working end to end against live traffic, not just against a deliberately staged test case.

## CA07: session hardening for accounts under active risk

Password change and MFA close the immediate credential gap, but do nothing about session behavior after the fact. I built CA07, scoped to the same High user risk condition as CA06, using session controls rather than grant controls: sign-in frequency set to require reauthentication every time, and persistent browser sessions set to never persistent.

CA06 handles the immediate credential response. CA07 keeps any high-risk account on a short reauthentication leash for as long as that risk stays open, not just at the moment of the triggering sign-in. Two policies, two different jobs, both responding to the same signal.

One limitation worth naming: session controls only take full effect against apps that support them, currently Office 365, Exchange Online, and SharePoint Online. CA07 is still scoped to all resources, but its actual enforcement strength is strongest within Microsoft's own suite. I didn't enable Conditional Access App Control on top of it, since that's a heavier control this scenario doesn't call for.

CA07 was built and validated in Report-only, same discipline as CA05 and CA06.

## Current state

CA05 validated in Report-only, staying in Report-only pending more sign-in history.
CA06 validated and enforced.
CA07 built and validated in Report-only.
Natalie Lopez's risk state open, under observation.

## Current state

CA05 validated in Report-only, staying in Report-only pending more sign-in history.
CA06 validated and enforced.
CA07 planned, not yet built.
Natalie Lopez's risk state open, under observation.

## Current state

CA05 validated in Report-only, staying in Report-only pending more sign-in history.
CA06 validated, enforced, and confirmed resolving a real risk case through self-remediation.
CA07 built and validated in Report-only.
Natalie Lopez's risk state: Remediated. Case closed.