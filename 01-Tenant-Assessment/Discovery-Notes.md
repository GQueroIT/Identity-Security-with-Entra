# Discovery Notes

## Objective

Assess the security posture of the 52 Logistics LLC Entra ID tenant and identify gaps in identity controls.

---

## Methodology

I reviewed the tenant's users, groups, and roles, along with its authentication settings, Conditional Access configuration, and Identity Protection capabilities.

---

## Observations

Going through the tenant, I found three Global Administrators, which is more standing privileged access than a company this size needs. Security defaults are enabled, which is Microsoft Entra ID's default state for new tenants. This means MFA registration is required tenant-wide, not scoped to any particular role, but the tenant has no Conditional Access policies layered on top to provide risk-based or role-differentiated enforcement.

---

## Skills Demonstrated

This phase demonstrated Entra ID administration, identity assessment, and risk analysis.