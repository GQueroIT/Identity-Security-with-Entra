# Phase 1 - Day 1
# Identity Security Fundamentals

## Objective

The objective of Day 1 was to understand why identity has become the primary security boundary in modern organizations and to learn the foundational concepts used throughout Microsoft Entra ID.

---

## Key Concepts

### Identity

An identity is any object capable of authenticating to a resource.

Examples include:

- Users
- Devices
- Applications
- Service Principals
- Managed Identities

---

### Authentication

Authentication answers the question:

> Who are you?

Authentication methods may include:

- Passwords
- Multi-Factor Authentication (MFA)
- Windows Hello for Business
- FIDO2 Security Keys
- Certificates
- Passkeys

Authentication occurs before authorization.

---

### Authorization

Authorization answers the question:

> What are you allowed to access?

Examples include:

- Access to Microsoft 365
- Access to SharePoint
- Access to GitHub
- Access to Azure Resources

Authorization occurs only after successful authentication.

---

### Identity Provider (IdP)

An Identity Provider verifies identities and provides authentication services.

Examples:

- Microsoft Entra ID
- Okta
- Google Workspace
- Active Directory Federation Services (AD FS)

Microsoft Entra ID serves as Microsoft's cloud Identity Provider.

---

### Active Directory vs Entra ID

Traditional Active Directory primarily manages on-premises identities and resources.

Entra ID manages cloud identities and provides access to cloud applications and services.

Protocols commonly associated with each platform include:

Active Directory:

- Kerberos
- LDAP
- NTLM

Entra ID:

- OAuth 2.0
- OpenID Connect (OIDC)
- SAML

---

### Zero Trust Principles

Zero Trust is built upon three core principles.

#### Verify Explicitly

Always validate:

- User identity
- Device compliance
- Location
- Sign-in risk
- Application sensitivity

---

#### Least Privilege

Users should receive only the minimum permissions required to perform their responsibilities.

Examples:

- Helpdesk Administrator
- User Administrator
- Authentication Administrator

Avoid assigning Global Administrator privileges unnecessarily.

---

#### Assume Breach

Organizations should operate under the assumption that attackers may already be present within the environment.

Security controls should focus on:

- Monitoring
- Segmentation
- Continuous evaluation
- Policy enforcement

---

### Service Principals

Service Principals represent an application's identity within an Entra ID tenant.

Analogy:

Application Registration = Birth Certificate

Service Principal = Employee Badge

---

## Lessons Learned

Traditional perimeter security focused primarily on protecting networks.

Modern organizations protect identities because users, devices, and applications interact from many locations outside of traditional corporate boundaries.

Identity is now considered the new security perimeter.