# Create-Assessment-Users.ps1
# Purpose: Create simulated users for the Entra Security Posture Assessment

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

if (-not (Get-Module Microsoft.Graph.Users -ListAvailable)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

Import-Module Microsoft.Graph.Users

Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

$Domain = "gquero52outlook.onmicrosoft.com"
$TempPassword = "TempP@ssw0rd2026!"

$Users = @(
    @{First="Angela"; Last="Rivera"; Department="Executive"; Title="Chief Executive Officer"},
    @{First="Marcus"; Last="Hill"; Department="Executive"; Title="Chief Financial Officer"},
    @{First="Denise"; Last="Carter"; Department="Executive"; Title="Chief Operations Officer"},
    @{First="Evelyn"; Last="Brooks"; Department="Executive"; Title="Chief Compliance Officer"},

    @{First="Gabriel"; Last="Admin"; Department="IT"; Title="Identity Administrator"},
    @{First="Jason"; Last="Miller"; Department="IT"; Title="Systems Administrator"},
    @{First="Priya"; Last="Shah"; Department="IT"; Title="Help Desk Technician"},
    @{First="Thomas"; Last="Brooks"; Department="IT"; Title="Security Analyst"},
    @{First="Rachel"; Last="Kim"; Department="IT"; Title="Microsoft 365 Administrator"},
    @{First="Omar"; Last="Reyes"; Department="IT"; Title="Cloud Support Technician"},

    @{First="Karen"; Last="Lopez"; Department="Human Resources"; Title="HR Manager"},
    @{First="Monica"; Last="Reed"; Department="Human Resources"; Title="HR Specialist"},
    @{First="Elena"; Last="Torres"; Department="Human Resources"; Title="Recruiter"},
    @{First="Daniel"; Last="Foster"; Department="Human Resources"; Title="Benefits Coordinator"},

    @{First="Robert"; Last="King"; Department="Finance"; Title="Finance Manager"},
    @{First="Samantha"; Last="Wells"; Department="Finance"; Title="Accounts Payable Specialist"},
    @{First="Anthony"; Last="Moore"; Department="Finance"; Title="Payroll Specialist"},
    @{First="Grace"; Last="Patel"; Department="Finance"; Title="Financial Analyst"},

    @{First="Brian"; Last="Scott"; Department="Sales"; Title="Sales Manager"},
    @{First="Ashley"; Last="Young"; Department="Sales"; Title="Account Executive"},
    @{First="Derek"; Last="Price"; Department="Sales"; Title="Sales Representative"},
    @{First="Nina"; Last="Bennett"; Department="Sales"; Title="Sales Representative"},
    @{First="Julian"; Last="Ross"; Department="Sales"; Title="Business Development Representative"},
    @{First="Maya"; Last="Collins"; Department="Sales"; Title="Customer Success Specialist"},

    @{First="Carlos"; Last="Santos"; Department="Operations"; Title="Operations Manager"},
    @{First="Jasmine"; Last="Cole"; Department="Operations"; Title="Operations Coordinator"},
    @{First="Victor"; Last="Hughes"; Department="Operations"; Title="Warehouse Supervisor"},
    @{First="Tanya"; Last="Morgan"; Department="Operations"; Title="Logistics Coordinator"},
    @{First="Kevin"; Last="Ward"; Department="Operations"; Title="Inventory Specialist"},
    @{First="Luis"; Last="Navarro"; Department="Operations"; Title="Field Operations Lead"},

    @{First="Liam"; Last="Contractor"; Department="Contractors"; Title="External Consultant"},
    @{First="Olivia"; Last="Vendor"; Department="Contractors"; Title="Vendor Support"},
    @{First="Noah"; Last="Temp"; Department="Contractors"; Title="Temporary Worker"},
    @{First="Sophia"; Last="Partner"; Department="Contractors"; Title="Partner Consultant"}
)

$ReportFolder = ".\11-PowerShell\Reports"

if (!(Test-Path $ReportFolder)) {
    New-Item -Path $ReportFolder -ItemType Directory | Out-Null
}

$Results = @()

foreach ($User in $Users) {
    $DisplayName = "$($User.First) $($User.Last)"
    $MailNickname = "$($User.First).$($User.Last)".ToLower()
    $UPN = "$MailNickname@$Domain"

    Write-Host "Processing $DisplayName..." -ForegroundColor Cyan

    $ExistingUser = Get-MgUser -Filter "userPrincipalName eq '$UPN'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "Already exists: $UPN" -ForegroundColor Yellow

        $Results += [PSCustomObject]@{
            DisplayName       = $DisplayName
            UserPrincipalName = $UPN
            Department        = $User.Department
            JobTitle          = $User.Title
            Status            = "Skipped - Already Exists"
        }

        continue
    }

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
            -Department $User.Department `
            -JobTitle $User.Title `
            -AccountEnabled:$true `
            -PasswordProfile $PasswordProfile | Out-Null

        Write-Host "Created: $UPN" -ForegroundColor Green

        $Results += [PSCustomObject]@{
            DisplayName       = $DisplayName
            UserPrincipalName = $UPN
            Department        = $User.Department
            JobTitle          = $User.Title
            Status            = "Created"
        }
    }
    catch {
        Write-Host "Failed: $UPN" -ForegroundColor Red

        $Results += [PSCustomObject]@{
            DisplayName       = $DisplayName
            UserPrincipalName = $UPN
            Department        = $User.Department
            JobTitle          = $User.Title
            Status            = "Failed: $($_.Exception.Message)"
        }
    }
}

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$ReportPath = "$ReportFolder\User-Creation-Report-$Timestamp.csv"

$Results | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "User creation process complete." -ForegroundColor Green
Write-Host "Report saved to: $ReportPath" -ForegroundColor Cyan
Write-Host "Temporary password used: $TempPassword" -ForegroundColor Yellow