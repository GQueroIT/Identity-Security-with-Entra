# Create-52Logistics-DepartmentGroups.ps1
# Purpose: Create department-based security groups and populate them for 52 Logistics LLC

Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups

Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All"

# Departments pulled from the existing user base
$Departments = @("Executive", "IT", "HR", "Finance", "Sales", "Operations", "Warehouse", "Compliance", "Security", "Marketing")

foreach ($Dept in $Departments) {

    try {
        # Create the security group for this department
        $Group = New-MgGroup `
            -DisplayName "$Dept-Group" `
            -MailEnabled:$false `
            -MailNickname "$($Dept)Group" `
            -SecurityEnabled:$true

        Write-Host "Created group: $Dept-Group" -ForegroundColor Green

        # Find users belonging to this department
        # ConsistencyLevel + CountVariable are required for filtering on non-indexed properties like department
        $Members = Get-MgUser -All -Filter "department eq '$Dept'" -ConsistencyLevel eventual -CountVariable MemberCount

        foreach ($Member in $Members) {
            New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $Member.Id
            Write-Host "  Added $($Member.DisplayName) to $Dept-Group" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "Failed on department: $Dept" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

Disconnect-MgGraph