# Invoke-UserLifecycleDemo.ps1
# Purpose: Demonstrate Microsoft Entra ID user lifecycle management with Microsoft Graph PowerShell

Import-Module Microsoft.Graph.Users

Connect-MgGraph -Scopes `
    "User.ReadWrite.All", `
    "Directory.ReadWrite.All"

$Domain = "52-logistics.com"
$ManagerUPN = "sofia.martinez@52-logistics.com"

$TempPassword = "TempP@ssw0rd2026!"

$User = @{
    FirstName = "Jordan"
    LastName  = "Reed"
    UPN       = "jordan.reed@$Domain"
    JobTitle  = "Operations Coordinator"
    Department = "Operations"
    Office    = "Queens Branch"
}

$PasswordProfile = @{
    Password = $TempPassword
    ForceChangePasswordNextSignIn = $true
}

Write-Host "`n[JOINER] Creating user..." -ForegroundColor Cyan

New-MgUser `
    -DisplayName "$($User.FirstName) $($User.LastName)" `
    -GivenName $User.FirstName `
    -Surname $User.LastName `
    -UserPrincipalName $User.UPN `
    -MailNickname "$($User.FirstName).$($User.LastName)" `
    -AccountEnabled:$true `
    -PasswordProfile $PasswordProfile `
    -JobTitle $User.JobTitle `
    -Department $User.Department `
    -OfficeLocation $User.Office `
    -UsageLocation "US"

Write-Host "User created: $($User.UPN)" -ForegroundColor Green

Start-Sleep -Seconds 5

Write-Host "`n[JOINER] Updating contact information..." -ForegroundColor Cyan

Update-MgUser `
    -UserId $User.UPN `
    -MobilePhone "(555)555-5555" `
    -StreetAddress "120 Main Street" `
    -City "Queens" `
    -State "New York" `
    -PostalCode "11368" `
    -Country "United States"

Write-Host "User profile updated." -ForegroundColor Green

Write-Host "`n[JOINER] Assigning manager..." -ForegroundColor Cyan

$Manager = Get-MgUser -UserId $ManagerUPN

Set-MgUserManagerByRef `
    -UserId $User.UPN `
    -OdataId "https://graph.microsoft.com/v1.0/users/$($Manager.Id)"

Write-Host "Manager assigned: $ManagerUPN" -ForegroundColor Green

Write-Host "`n[MOVER] Promoting user..." -ForegroundColor Cyan

Update-MgUser `
    -UserId $User.UPN `
    -JobTitle "Operations Supervisor" `
    -Department "Operations" `
    -OfficeLocation "New York HQ"

Write-Host "User promoted and profile updated." -ForegroundColor Green

Write-Host "`n[SECURITY] Revoking active sessions..." -ForegroundColor Cyan

Revoke-MgUserSignInSession -UserId $User.UPN

Write-Host "User sessions revoked." -ForegroundColor Green

Write-Host "`n[LEAVER] Blocking sign-in..." -ForegroundColor Cyan

Update-MgUser `
    -UserId $User.UPN `
    -AccountEnabled:$false

Write-Host "User sign-in blocked." -ForegroundColor Green

Write-Host "`n[LEAVER] Deleting user..." -ForegroundColor Cyan

Remove-MgUser -UserId $User.UPN -Confirm:$false

Write-Host "User deleted and moved to Deleted Users." -ForegroundColor Green

Write-Host "`n[RESTORE] Restoring deleted user..." -ForegroundColor Cyan

Start-Sleep -Seconds 30

$DeletedUser = Get-MgDirectoryDeletedItemAsUser -All |
    Where-Object { $_.DisplayName -eq "$($User.FirstName) $($User.LastName)" }

if ($null -eq $DeletedUser) {
    Write-Host "Deleted user was not found. Restore skipped." -ForegroundColor Red
}
else {
    Restore-MgDirectoryDeletedItem -DirectoryObjectId $DeletedUser.Id
    Write-Host "User restored from Deleted Users." -ForegroundColor Green
}