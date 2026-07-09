# Architecture Decisions

## Decision 01
Cloud-only identity model selected instead of hybrid identity.

Reason:
52 Logistics LLC does not maintain an on-premises Active Directory infrastructure. A cloud-only model simplifies administration, reduces infrastructure costs, and aligns with the organization's cloud-first strategy.

---

## Decision 02
Microsoft Entra ID selected as the identity provider.

Reason:
Provides centralized authentication, authorization, RBAC, Conditional Access, Identity Protection, and governance capabilities for Microsoft 365.

---

## Decision 03
Role-Based Access Control (RBAC) adopted.

Reason:
Administrative permissions are delegated according to job responsibilities, supporting the principle of Least Privilege.

---

## Decision 04
Zero Trust selected as the security model.

Reason:
Every access request is continuously verified regardless of user location, reducing the risk of unauthorized access.

---

## Decision 05
Department-based groups will be used.

Reason:
Simplifies permission management, licensing, Conditional Access targeting, and future automation.