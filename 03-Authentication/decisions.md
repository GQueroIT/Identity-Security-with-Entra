# Decisions

## Decision 01: Lowered Smart Lockout Threshold

Changed the lockout threshold from the default of 10 failed attempts to 5.

Reason: A lower threshold reduces the window an attacker has to brute-force a password before the account locks, at an acceptable cost to legitimate users who occasionally mistype a password. Given 52 Logistics has no Conditional Access policies yet to layer on additional risk-based protection, tightening this baseline control was worth prioritizing early.

---

## Decision 02: Custom Banned Password List

Enabled a custom banned password list including 52logistics, 52Logistics, Azure, NewYork, and Fifty2Logistics.

Reason: Default banned password lists don't account for organization-specific terms employees are likely to base passwords on. Company name variations and location terms are exactly what an attacker would try first in a targeted guess, so blocking them directly closes an obvious gap the default list wouldn't catch.

---

## Decision 03: Left "Windows Server AD Password Protection" Enabled Despite No On-Prem AD

Left this setting enabled and set to Enforced mode.

Reason: 52 Logistics' identity architecture is cloud-only per the Phase 02 architecture decisions, no on-premises Active Directory exists in this environment. This toggle only has an effect when a domain controller is running the password protection proxy agent, so in this tenant it's currently inert. I left it enabled anyway as a forward-looking setting, if 52 Logistics ever stands up on-prem infrastructure, or if this project's scenario evolves, the setting is already correctly configured rather than needing to be revisited.

---

## Decision 04: Custom Authentication Strength Requiring WHFB or Password + Authenticator

Built a custom authentication strength allowing either Windows Hello for Business/Platform Credential, or Password combined with Microsoft Authenticator push notification.

Reason: I wanted a defined strength that reflects two realistic, phishing-resistant-leaning paths rather than relying only on the built-in "Multifactor authentication" strength, which allows a broader set of methods than I want scoped for stronger access requirements later in the Conditional Access phase.

---

## Decision 05: Enabled SSPR for All Users

Changed self-service password reset from None to All, directly addressing the Phase 01 finding.

Reason: With SSPR disabled, every password reset required administrator involvement, adding operational overhead and creating a social engineering risk by training users to expect resets through a human process. Enabling SSPR tenant-wide removes that dependency while still requiring two authentication methods to complete a reset.

---

## Decision 06: Registration Campaign Targeting Microsoft Authenticator

Enabled a registration campaign for all users, targeting Microsoft Authenticator specifically, with a 1-day snooze limit and a capped number of snoozes rather than unlimited deferral.

Reason: Having a method available doesn't mean users register for it. A capped snooze period pushes registration forward without being disruptive on day one, and choosing Authenticator specifically over passkeys as the campaign target reflects that most users don't have FIDO2 hardware yet, but do have a smartphone.