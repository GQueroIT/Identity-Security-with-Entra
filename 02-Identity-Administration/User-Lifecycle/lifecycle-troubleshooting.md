# Lifecycle Troubleshooting

## Overview

This document covers the issues I ran into during the User Lifecycle Management lab and how I worked through them.

Troubleshooting is just part of the job as a Microsoft 365 or Identity Administrator. Most tasks go as expected, but sync delays, permission gaps, and quirks in how the Graph API behaves can throw things off.

These are the scenarios I hit while working in Microsoft Entra ID and Microsoft Graph PowerShell.

---

# Scenario 1 - Unable to Restore Deleted User

## Issue

After deleting a user through Microsoft Graph PowerShell, the restore failed. PowerShell came back with an error saying it couldn't find the specified user.

## Cause

My script was looking for the deleted user by their original UPN. Entra ID changes the UPN of deleted users by adding a unique identifier while the account sits in the Deleted Users container. Since that original UPN didn't exist anymore, Graph couldn't find the object.

## Resolution

I pulled the deleted user by Display Name and Object ID instead of the original UPN.

```powershell
$DeletedUser = Get-MgDirectoryDeletedItemAsUser -All |
Where-Object DisplayName -eq "Jordan Reed"

Restore-MgDirectoryDeletedItem -DirectoryObjectId $DeletedUser.Id
```

## Lesson Learned

Don't restore deleted Entra ID users by assuming the original UPN still applies. Use the deleted object ID or something else that's actually reliable.

---

# Scenario 2 - User Not Found After Restore

## Issue

Right after restoring a deleted user, Graph couldn't locate the account.

## Cause

Entra ID needs a bit of time to fully bring the object back into Active Users. The restore had actually worked, replication just hadn't caught up yet.

## Resolution

Waited about 30 seconds, then checked again.

```powershell
Get-MgUser -UserId "jordan.reed@52-logistics.com"
```

## Lesson Learned

Cloud identity changes aren't instant. When automating lifecycle steps, I need to build in room for replication delays.

---

# Scenario 3 - Insufficient Microsoft Graph Permissions

## Issue

Some Graph commands fail outright if the delegated permissions haven't been granted.

## Resolution

Connected to Graph with the scopes actually needed:

```powershell
Connect-MgGraph -Scopes `
"User.ReadWrite.All",
"Directory.ReadWrite.All",
"Group.ReadWrite.All"
```

## Lesson Learned

Scripts should only request the permissions they actually need for the task, nothing broader.

---

# Scenario 4 - Account Verification

## Issue

After making admin changes, I needed to confirm the account actually reflected what I expected.

## Resolution

Checked:

- Display Name
- User Principal Name
- Department
- Job Title
- Account Status

```powershell
Get-MgUser -UserId "jordan.reed@52-logistics.com" |
Select DisplayName,
       UserPrincipalName,
       JobTitle,
       Department,
       AccountEnabled
```

---

# Administrative Best Practices

A few things that made lifecycle admin work more consistent and reliable:

- Verify user creation before continuing automation.
- Confirm profile updates after major changes.
- Allow time for cloud replication when appropriate.
- Verify deleted users before attempting restoration.
- Use Object IDs when performing restore operations.
- Test automation in a lab environment before production use.
- Record troubleshooting steps for future reference.

---

# Summary

This lab made it clear that I needed to understand how Entra ID behaves during creation, modification, deletion, and restoration to troubleshoot any of this effectively.

Writing these scenarios down gives me something to reference next time, and it's a record of what I actually learned by working through it hands-on.