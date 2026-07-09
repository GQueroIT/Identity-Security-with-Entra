# Create-52Logistics-TestUsers.ps1
# Purpose: Create 20 Microsoft Entra ID lab users for 52 Logistics LLC

# Install Microsoft Graph module if needed
if (-not (Get-Module -ListAvailable Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

Import-Module Microsoft.Graph.Users

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

# Tenant domain
$Domain = "52-logistics.com"   # Change this if your verified domain is different

# Temporary password for lab users
$TempPassword = "TempP@ssw0rd2026!"

# User list for identity, group, licensing, and policy testing
$Users = @(
    @{First="Alicia"; Last="Rivera"; Department="Executive"; JobTitle="Chief Executive Officer"; Office="New York HQ"},
    @{First="Marcus"; Last="Johnson"; Department="Executive"; JobTitle="Chief Operations Officer"; Office="New York HQ"},
    @{First="Sofia"; Last="Martinez"; Department="IT"; JobTitle="IT Manager"; Office="New York HQ"},
    @{First="Daniel"; Last="Kim"; Department="IT"; JobTitle="Systems Administrator"; Office="New York HQ"},
    @{First="Priya"; Last="Patel"; Department="IT"; JobTitle="Help Desk Technician"; Office="New York HQ"},
    @{First="Anthony"; Last="Torres"; Department="HR"; JobTitle="HR Manager"; Office="New York HQ"},
    @{First="Jessica"; Last="Williams"; Department="HR"; JobTitle="HR Coordinator"; Office="New York HQ"},
    @{First="Robert"; Last="Chen"; Department="Finance"; JobTitle="Finance Manager"; Office="New York HQ"},
    @{First="Emily"; Last="Davis"; Department="Finance"; JobTitle="Payroll Specialist"; Office="New York HQ"},
    @{First="Kevin"; Last="Brown"; Department="Sales"; JobTitle="Sales Manager"; Office="Bronx Branch"},
    @{First="Natalie"; Last="Lopez"; Department="Sales"; JobTitle="Account Executive"; Office="Bronx Branch"},
    @{First="Chris"; Last="Miller"; Department="Sales"; JobTitle="Account Executive"; Office="Queens Branch"},
    @{First="Amanda"; Last="Wilson"; Department="Operations"; JobTitle="Operations Manager"; Office="Bronx Branch"},
    @{First="Jose"; Last="Garcia"; Department="Operations"; JobTitle="Route Supervisor"; Office="Bronx Branch"},
    @{First="Brianna"; Last="Moore"; Department="Operations"; JobTitle="Dispatcher"; Office="Queens Branch"},
    @{First="Michael"; Last="Anderson"; Department="Warehouse"; JobTitle="Warehouse Manager"; Office="Bronx Warehouse"},
    @{First="Luis"; Last="Santiago"; Department="Warehouse"; JobTitle="Inventory Specialist"; Office="Bronx Warehouse"},
    @{First="Rachel"; Last="Taylor"; Department="Compliance"; JobTitle="Compliance Analyst"; Office="New York HQ"},
    @{First="Omar"; Last="Hassan"; Department="Security"; JobTitle="Security Analyst"; Office="New York HQ"},
    @{First="Vanessa"; Last="Clark"; Department="Marketing"; JobTitle="Marketing Coordinator"; Office="New York HQ"}
)

foreach ($User in $Users) {

    $DisplayName = "$($User.First) $($User.Last)"
    $UPN = ("{0}.{1}@{2}" -f $User.First, $User.Last, $Domain).ToLower()
    $MailNickname = ("{0}.{1}" -f $User.First, $User.Last).ToLower()

    $PasswordProfile = @{
        Password = $TempPassword
        ForceChangePasswordNextSignIn = $true
    }

    try {
        New-MgUser `
            -DisplayName $DisplayName `
            -GivenName $User.First `
            -Surname $User.Last `
            -UserPrincipalName $UPN `
            -MailNickname $MailNickname `
            -AccountEnabled:$true `
            -Department $User.Department `
            -JobTitle $User.JobTitle `
            -OfficeLocation $User.Office `
            -UsageLocation "US" `
            -PasswordProfile $PasswordProfile

        Write-Host "Created user: $DisplayName - $UPN" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create user: $DisplayName" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

Disconnect-MgGraph