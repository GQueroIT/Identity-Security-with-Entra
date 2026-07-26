<#
.SYNOPSIS
    Inventories every workload identity in the 52 Logistics tenant.

.DESCRIPTION
    Fulfills the day-one Assumptions.md commitment to inventory service principals
    inherited with the tenant. Runs read-only, before any Phase 08 changes land,
    so the output reflects the tenant as it actually sits.

    For every service principal, the script:
      - Classifies it as Microsoft first-party or non-Microsoft
      - Flags credentials (client secrets and certificates) with expiration dates
      - Flags ownerless non-Microsoft apps
      - Flags admin-consented high-privilege application permissions

    Exports full results to CSV and prints a findings summary to console.

.NOTES
    Project : Identity-Security-with-Entra / Phase 08 - Workload Identities
    Author  : Gabriel Quero
    Scopes  : Application.Read.All, Directory.Read.All (delegated, read-only)
#>

# --- Connect ---------------------------------------------------------------

$clientId   = "9cc563d6-ef62-41f3-a276-96fec9fbaba0"
$tenantId   = "e273afa9-80e1-40af-af34-2c9accd77009"
$thumbprint = "0C234C7485389B2AE7AB9DB66E033AF160980792"

Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumbprint $thumbprint -NoWelcome

$tenantId = (Get-MgContext).TenantId
Write-Host "Connected to tenant: $tenantId" -ForegroundColor Cyan

# Microsoft's own service tenants. A service principal whose owning org is one
# of these is a Microsoft first-party app, not something 52 Logistics onboarded.
$microsoftTenantIds = @(
    "f8cdef31-a31e-4b4a-93e4-5f571e91255a",  # Microsoft Services
    "72f988bf-86f1-41af-91ab-2d7cd011db47"   # Microsoft
)

# Application permissions that warrant a closer look if admin-consented.
$highPrivilegePatterns = @(
    "*.ReadWrite.All",
    "Directory.*",
    "RoleManagement.*",
    "AppRoleAssignment.ReadWrite.All",
    "Application.ReadWrite.All",
    "Mail.*",
    "User.ReadWrite.All",
    "Group.ReadWrite.All"
)

# --- Collect ---------------------------------------------------------------

Write-Host "Retrieving all service principals..." -ForegroundColor Cyan

$servicePrincipals = Get-MgServicePrincipal -All -Property `
    Id, AppId, DisplayName, AppOwnerOrganizationId, ServicePrincipalType, `
    AccountEnabled, PasswordCredentials, KeyCredentials, SignInAudience, Tags

Write-Host "Found $($servicePrincipals.Count) service principals." -ForegroundColor Cyan

# Cache of resource SP app roles so permission names resolve without
# re-querying Graph for every assignment.
$appRoleCache = @{}

$inventory = foreach ($sp in $servicePrincipals) {

    $isMicrosoft = $microsoftTenantIds -contains $sp.AppOwnerOrganizationId

    # --- Credentials ---
    $secrets = @($sp.PasswordCredentials)
    $certs   = @($sp.KeyCredentials)

    $credentialSummary = @()
    foreach ($s in $secrets) { $credentialSummary += "Secret expires $($s.EndDateTime)" }
    foreach ($c in $certs)   { $credentialSummary += "Certificate expires $($c.EndDateTime)" }

    # --- Owners (only worth the extra call for non-Microsoft apps) ---
    $ownerCount = $null
    if (-not $isMicrosoft) {
        $ownerCount = @(Get-MgServicePrincipalOwner -ServicePrincipalId $sp.Id -ErrorAction SilentlyContinue).Count
    }

    # --- Admin-consented application permissions ---
    $highPrivPermissions = @()
    if (-not $isMicrosoft) {
        $assignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -All -ErrorAction SilentlyContinue

        foreach ($assignment in $assignments) {
            if (-not $appRoleCache.ContainsKey($assignment.ResourceId)) {
                $resourceSp = Get-MgServicePrincipal -ServicePrincipalId $assignment.ResourceId -Property AppRoles -ErrorAction SilentlyContinue
                $appRoleCache[$assignment.ResourceId] = $resourceSp.AppRoles
            }

            $role = $appRoleCache[$assignment.ResourceId] | Where-Object { $_.Id -eq $assignment.AppRoleId }
            if ($role) {
                foreach ($pattern in $highPrivilegePatterns) {
                    if ($role.Value -like $pattern) {
                        $highPrivPermissions += $role.Value
                        break
                    }
                }
            }
        }
    }

    [PSCustomObject]@{
        DisplayName          = $sp.DisplayName
        AppId                = $sp.AppId
        Type                 = $sp.ServicePrincipalType
        Classification       = if ($isMicrosoft) { "Microsoft first-party" } else { "Non-Microsoft" }
        AccountEnabled       = $sp.AccountEnabled
        SecretCount          = $secrets.Count
        CertificateCount     = $certs.Count
        Credentials          = ($credentialSummary -join "; ")
        OwnerCount           = $ownerCount
        HighPrivPermissions  = ($highPrivPermissions | Sort-Object -Unique) -join "; "
    }
}

# --- Export ----------------------------------------------------------------

$timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$exportPath = ".\WorkloadIdentityInventory-$timestamp.csv"
$inventory | Export-Csv -Path $exportPath -NoTypeInformation
Write-Host "`nFull inventory exported to $exportPath" -ForegroundColor Green

# --- Findings summary ------------------------------------------------------

$nonMicrosoft   = $inventory | Where-Object { $_.Classification -eq "Non-Microsoft" }
$withCreds      = $nonMicrosoft | Where-Object { $_.SecretCount -gt 0 -or $_.CertificateCount -gt 0 }
$ownerless      = $nonMicrosoft | Where-Object { $_.OwnerCount -eq 0 }
$highPriv       = $nonMicrosoft | Where-Object { $_.HighPrivPermissions }

Write-Host "`n===== WORKLOAD IDENTITY INVENTORY SUMMARY =====" -ForegroundColor Yellow
Write-Host "Total service principals      : $($inventory.Count)"
Write-Host "Microsoft first-party         : $(($inventory | Where-Object { $_.Classification -eq 'Microsoft first-party' }).Count)"
Write-Host "Non-Microsoft                 : $($nonMicrosoft.Count)"
Write-Host ""
Write-Host "--- Findings requiring review (non-Microsoft only) ---" -ForegroundColor Yellow
Write-Host "Carrying credentials          : $($withCreds.Count)"
Write-Host "Ownerless                     : $($ownerless.Count)"
Write-Host "High-privilege app permissions: $($highPriv.Count)"

if ($withCreds)  { Write-Host "`nCredentialed apps:" -ForegroundColor Yellow; $withCreds | Format-Table DisplayName, Credentials -AutoSize }
if ($ownerless)  { Write-Host "Ownerless apps:" -ForegroundColor Yellow; $ownerless | Format-Table DisplayName, AppId -AutoSize }
if ($highPriv)   { Write-Host "High-privilege apps:" -ForegroundColor Yellow; $highPriv | Format-Table DisplayName, HighPrivPermissions -AutoSize }

Disconnect-MgGraph