# Leaver Process

## Overview

This lab covers offboarding an employee in Microsoft 365 and Microsoft Entra ID. The goal is to cut off access right away while still being able to recover the account if the deletion was a mistake or the employee comes back within the retention window.

I did this through the Microsoft 365 Admin Center, the Microsoft Entra Admin Center, and Microsoft Graph PowerShell.

---

## Business Scenario

Kevin Brown left 52 Logistics.

IT needed to shut off his access to company resources right away, but still keep the option to restore the account if something came up.

Having a set process for this cuts down on the security risk that comes with employees leaving.

---

# Administrative Tasks Performed

## Revoked Active Sessions

Forced Kevin's account to sign out of every active Microsoft 365 session. This kills his existing authentication tokens immediately, so he'd have to sign back in to get anywhere.

## Blocked User Sign-in

Disabled his ability to authenticate at all. This locks him out going forward, but the account itself is still there if I need to review it later.

## Deleted the User Account

Removed him from Active Users. The account didn't disappear, it moved into the Deleted Users container, where it can be restored during Microsoft's retention period.

## Restored Deleted User

Pulled the account back out of Deleted Users. The restore put him back in Active Users with his identity intact, and Microsoft generated a new temporary password automatically as part of that process.

## Verified User Restoration

Checked that the restored account showed up correctly in Active Users:

- User Principal Name (UPN)
- Display Name
- Account Status
- User Properties

---

## PowerShell Automation

I ran through the same offboarding process in Microsoft Graph PowerShell:

- Revoking user sessions
- Blocking sign-in
- Deleting the user
- Restoring the deleted user
- Verifying successful restoration

I hit a snag during testing: the restore kept failing because the deleted user object wasn't coming back correctly right after deletion. I fixed it by having the script pull the deleted directory object first, then restore from that. Stuff like this is just part of writing automation that actually holds up.

---

## Security Considerations

A proper offboarding process needs to cover:

- Revoke active sessions
- Block sign-in
- Remove administrative roles
- Remove group memberships
- Remove licenses when appropriate
- Preserve mailbox and OneDrive data if required
- Retain audit logs for investigation or compliance purposes

Skipping any of these is how former employees end up with access they shouldn't still have.

---

## Skills Demonstrated

- Microsoft 365 Administration
- Microsoft Entra ID
- Identity Lifecycle Management
- User Offboarding
- Session Revocation
- Account Recovery
- Microsoft Graph PowerShell
- Administrative Troubleshooting

---

## Outcome

Walked through the full offboarding lifecycle for Kevin Brown's account: revoked access, deleted the account, restored it, and confirmed his identity information came through intact. Did this through both the GUI and PowerShell, including fixing a scripting issue I ran into along the way.