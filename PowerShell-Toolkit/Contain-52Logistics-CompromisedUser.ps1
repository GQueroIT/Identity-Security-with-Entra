<#
.SYNOPSIS
    Contains a compromised user account in a single call: disables the 
    account, revokes active sessions, and confirms the user as 
    compromised in Identity Protection.

.DESCRIPTION
    Automates Stage 3 (Contain) of Runbook-Compromised-User.md. Runs 
    delegated and interactive by design, not app-only. Containment is 
    a human decision made under pressure, and the sign-in log should 
    show which admin ran it, under which PIM activation, with which 
    justification. Requires the Tier 2 Support group (User 
    Administrator) and Security Administrator to be active via PIM 
    before running.

.PARAMETER UserPrincipalName
    UPN of the user to contain.

.PARAMETER Justification
    Ticket number or incident reference. Written to the transcript log.

.PARAMETER WhatIf
    Shows what would happen without making any changes.

.EXAMPLE
    .\Contain-52Logistics-CompromisedUser.ps1 -UserPrincipalName natalie.lopez@52logisticsllc.onmicrosoft.com -Justification "INC-0092"

.EXAMPLE
    .\Contain-52Logistics-CompromisedUser.ps1 -UserPrincipalName natalie.lopez@52logisticsllc.onmicrosoft.com -Justification "INC-0092" -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [string]$Justification
)

$ErrorActionPreference = "Stop"
$logFile = "Contain-Log-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

Write-Log "Containment script started for $UserPrincipalName"
Write-Log "Justification: $Justification"

# Required delegated scopes: User.ReadWrite.All, User.RevokeSessions.All, IdentityRiskyUser.ReadWrite.All
Connect-MgGraph -Scopes "User.ReadWrite.All", "User.RevokeSessions.All", "IdentityRiskyUser.ReadWrite.All" -NoWelcome

$context = Get-MgContext
Write-Log "Connected as $($context.Account), AuthType $($context.AuthType)"

if ($context.AuthType -eq "AppOnly") {
    Write-Log "ERROR: This script must run delegated and interactive. Aborting."
    throw "App-only session detected. Containment requires an accountable human identity."
}

try {
    $user = Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
    Write-Log "Target confirmed: $($user.DisplayName) ($($user.Id))"
}
catch {
    Write-Log "ERROR: Could not resolve user $UserPrincipalName. $($_.Exception.Message)"
    throw
}

# Step 1: Disable the account
if ($PSCmdlet.ShouldProcess($user.DisplayName, "Disable account")) {
    Update-MgUser -UserId $user.Id -AccountEnabled:$false
    $verify = Get-MgUser -UserId $user.Id -Property AccountEnabled
    Write-Log "Account disabled. AccountEnabled = $($verify.AccountEnabled)"
}

# Step 2: Revoke all active sessions
if ($PSCmdlet.ShouldProcess($user.DisplayName, "Revoke sign-in sessions")) {
    Revoke-MgUserSignInSession -UserId $user.Id
    Write-Log "Sessions revoked."
}

# Step 3: Confirm compromised in Identity Protection
if ($PSCmdlet.ShouldProcess($user.DisplayName, "Confirm compromised")) {
    Confirm-MgRiskyUserCompromised -UserIds @($user.Id)
    Write-Log "Marked as confirmed compromised in Identity Protection."
}

Write-Log "Containment complete for $UserPrincipalName. Proceed to Runbook Stage 4: Remediate."
Write-Log "Log saved to $logFile"

Disconnect-MgGraph | Out-Null