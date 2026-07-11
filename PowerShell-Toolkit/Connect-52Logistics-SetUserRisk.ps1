# Connect-52Logistics-SetUserRisk.ps1
# Sets a test user's risk state to "confirmedCompromised" to validate CA06 (User Risk)
# Requires the IdentityRiskyUser.ReadWrite.All permission scope

Connect-MgGraph -Scopes "IdentityRiskyUser.ReadWrite.All"

# Replace with Natalie Lopez's actual Object ID
$userId = "ff6204a0-e68f-4eca-8f09-977ac45f081d"

$body = @{
    userIds = @($userId)
} | ConvertTo-Json

Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/identityProtection/riskyUsers/confirmCompromised" `
    -Body $body