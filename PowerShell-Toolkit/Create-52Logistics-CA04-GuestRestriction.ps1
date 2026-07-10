<#
.SYNOPSIS
    Creates CA04 - Restrict Guest and External User Access, a new Conditional Access policy
    for 52 Logistics LLC.

.DESCRIPTION
    Requires MFA for every guest and external user sign-in across all cloud apps. Guest and
    external accounts are one of the least visible risks in a tenant, since they can end up
    invited into Teams or SharePoint without ever going through the same hardening applied
    to internal users. This policy closes that gap.

    Creates the policy in Report-only by default. Review the Report-only results in Sign-in
    logs before switching State to "enabled".

.NOTES
    Requires the Microsoft.Graph.Identity.SignIns module.
    Requires the Policy.ReadWrite.ConditionalAccess and Policy.Read.All scopes.

    Fill in $BreakGlassGroupId below with your Break-Glass Group's object Id before running.
    Find it with: Get-MgGroup -Filter "displayName eq 'Break-Glass Group'" | Select Id
#>

Import-Module Microsoft.Graph.Identity.SignIns -ErrorAction Stop

if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess", "Policy.Read.All"
}

# --- Fill in before running ---
$BreakGlassGroupId = "21f20b43-a3c4-4b59-9217-ab678584dafa"

# --- Policy definition ---
$PolicyParams = @{
    DisplayName = "CA04 - Restrict Guest and External User Access"
    State       = "enabledForReportingButNotEnforced"
    Conditions  = @{
        Applications = @{
            IncludeApplications = @("All")
        }
        Users = @{
            IncludeGuestsOrExternalUsers = @{
                GuestOrExternalUserTypes = "b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,internalGuest,serviceProvider,otherExternalUser"
                ExternalTenants          = @{
                    MembershipKind = "all"
                }
            }
            ExcludeGroups = @($BreakGlassGroupId)
        }
    }
    GrantControls = @{
        Operator        = "OR"
        BuiltInControls = @("mfa")
    }
}

Write-Host "Creating policy: $($PolicyParams.DisplayName)" -ForegroundColor Cyan
Write-Host "State: $($PolicyParams.State) (switch to 'enabled' only after validating Report-only results)" -ForegroundColor Yellow

$NewPolicy = New-MgIdentityConditionalAccessPolicy -BodyParameter $PolicyParams

Write-Host "Created policy '$($NewPolicy.DisplayName)' with Id: $($NewPolicy.Id)" -ForegroundColor Green