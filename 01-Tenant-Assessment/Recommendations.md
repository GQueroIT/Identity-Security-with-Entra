# Recommendations

## Reduce Standing Privileged Access

Global Administrator access should move from standing assignment to just-in-time activation. This is what Privileged Identity Management is built for, and it's exactly what I'll be configuring in the Privileged Access phase of this project.

---

## Replace Security Defaults with Conditional Access

Rather than continuing to rely on Microsoft's one-size-fits-all security defaults, 52 Logistics needs Conditional Access policies that actually reflect how the organization operates. That means stronger requirements for privileged roles specifically, risk-based sign-in evaluation, and device compliance checks for users accessing resources from unmanaged devices. This is a standard, expected maturity step, most organizations start on security defaults and graduate to Conditional Access once they need differentiated policy, and it's the direct focus of the Conditional Access phase of this project. Passwordless authentication is worth evaluating as a longer-term improvement once Conditional Access is in place, but it's a secondary step, not the primary fix.

---

## Implement Conditional Access Policies

The tenant needs baseline Conditional Access policies that account for sign-in risk, device compliance, and location, especially given how much of the 52 Logistics workforce is accessing resources remotely. This is the focus of the Conditional Access phase.

---

## Enable Self-Service Password Reset

SSPR should be enabled for all users. It reduces both administrative overhead and the social engineering risk that comes with password resets running entirely through a human help desk process.

---

## Properly Isolate the Break-Glass Account

The emergency admin account needs to be treated as true break-glass, not as a third general-purpose Global Admin. That means excluding it from Conditional Access policies once they exist, so it isn't affected by the same conditions that might be locking out other admins. It also means using a long, complex, non-expiring credential stored securely outside normal password rotation, and setting up dedicated monitoring and alerting on any sign-in to this account specifically, since it should almost never be used. This will get addressed directly as part of the Conditional Access phase, where I'll be excluding it by design and documenting why.