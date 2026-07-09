# Findings

## Excessive Standing Privileged Access

Three accounts hold Global Administrator, the highest-privilege role in Entra ID, on a standing basis. That's more people with full tenant control than 52 Logistics actually needs day to day, and none of that access is time-bound or reviewed. If any one of those accounts is compromised, the blast radius is the entire tenant.

---

## Reliance on Security Defaults Instead of Conditional Access

The tenant is currently protected only by Microsoft's security defaults, which is the baseline MFA enforcement every new Entra ID tenant ships with. Security defaults require MFA registration across the entire user base, which sounds sufficient on paper, but it's a one-size-fits-all control with no ability to differentiate by role, risk level, device compliance, or location. Every user, from a driver signing in from a personal phone to an account holding Global Administrator, gets treated identically. There's no way to require stronger controls for privileged roles specifically, no way to evaluate sign-in risk before granting access, and no way to account for the fact that 52 Logistics' workforce is authenticating from a mix of managed and unmanaged devices. Security defaults are a reasonable starting point, but they're not a substitute for a deliberate access strategy.

---

## No Conditional Access Policies

There's nothing in place to evaluate sign-in risk, device compliance, or location before granting access. Every sign-in is treated the same regardless of context, which means there's no way to block or challenge a login that looks suspicious.

---

## Self-Service Password Reset Disabled

With SSPR turned off, every password reset has to go through an administrator manually. Beyond the operational overhead, that's also a support-desk social engineering risk, since it trains users and staff to expect password resets to come through a human process that could be impersonated.