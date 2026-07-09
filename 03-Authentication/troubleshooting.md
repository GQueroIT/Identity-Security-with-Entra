# Troubleshooting

## Windows Hello for Business — Deferred, Not Tested Hands-On

I initially planned to configure Windows Hello for Business against a physical or virtual device to validate the custom authentication strength built in this phase. After scoping out the setup required, an Entra-joined Windows 10/11 client, not a domain-joined or Windows Server device given the tenant's cloud-only architecture, I made the call to defer this given the time investment relative to the dev tenant's limited remaining access. I prioritized Conditional Access and Privileged Identity Management, which have broader tenant-wide impact, over device-level biometric enrollment. The authentication strength referencing WHFB is configured and ready to be validated if time allows later in the project.

---

## FIDO2 — No Physical Hardware Available

No physical FIDO2 security key was available to test registration or sign-in. Reviewing the authentication methods policy, I also noticed Passkey (FIDO2) shows as Enabled at the policy level but has no Target group configured, unlike Microsoft Authenticator, TAP, Software OATH, and Email OTP, which are all explicitly scoped to All users. This suggests the method may not actually be usable by any user in its current state regardless of hardware availability, worth revisiting if FIDO2 becomes a priority in a later phase.

---

## Windows Server AD Password Protection Toggle

Noticed this setting exists and defaults to enabled with Audit mode even in a tenant with no on-premises Active Directory. Confirmed via Microsoft's documentation that this setting has no effect without a domain controller running the password protection proxy, it isn't a misconfiguration, just a setting that doesn't currently apply to this environment. See decisions.md for the reasoning behind leaving it enabled anyway.