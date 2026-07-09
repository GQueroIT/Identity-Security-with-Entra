# Guest Users

## Overview

Guest users let external people access resources in Entra ID without needing a full organizational account. This is how I'd bring in vendors, contractors, partners, consultants, or customers without giving them a real employee identity.

Guest accounts are the core of how Microsoft Entra handles B2B collaboration.

## Business Scenario

52 Logistics occasionally works with third-party vendors who need temporary access to things like:

- Microsoft Teams
- SharePoint Online
- Project documentation
- Internal collaboration sites

Instead of creating a standard employee account for them, I'd invite them in as guest users and only grant what they actually need for the work.

## Guest User Lifecycle

### Invitation

I send an invitation to the external person's email. They get invited to join the Entra tenant.

### Acceptance

The external user accepts and authenticates through whatever identity provider they already use:

- Microsoft Account
- Microsoft 365 Account
- Azure AD Organization
- Google Account (in supported scenarios)

### Access Assignment

Once they've accepted, I assign access to:

- Microsoft Teams
- SharePoint Sites
- Microsoft 365 Groups
- Enterprise Applications
- Individual resources

They only get what's explicitly assigned. Nothing more.

### Ongoing Management

While the guest account is active, I check in on:

- Group memberships
- Application assignments
- Sign-in activity
- Whether there's still a business reason for them to have access

Regular reviews are what keep external access from quietly sticking around after it's needed.

### Offboarding

Once the collaboration wraps up:

- Remove resource assignments
- Remove group memberships
- Delete the guest account
- Check audit logs if needed

Clearing out inactive guest accounts keeps the attack surface smaller.

## Security Considerations

Guest accounts need the same kind of protection as any other identity:

- Multi-Factor Authentication (MFA)
- Conditional Access Policies
- Access Reviews
- Least Privilege
- Time-limited access when it makes sense

External users should never end up with more access than the work actually calls for.

## Administrative Best Practices

- Verify there's an actual business need before inviting someone external.
- Grant access only to what's required.
- Review guest accounts regularly.
- Remove inactive guest users.
- Monitor guest sign-in activity.
- Apply Conditional Access policies when possible.

## Skills Demonstrated

- Microsoft Entra ID
- External Identity Management
- B2B Collaboration
- Identity Lifecycle Management
- Least Privilege Administration
- Microsoft 365 Administration

## Outcome

Went through how guest users work in Entra ID as part of the identity lifecycle strategy for 52 Logistics. External collaboration wasn't actually needed at this stage of the project, but I documented the planning and considerations so it's ready to go once B2B collaboration comes into play.