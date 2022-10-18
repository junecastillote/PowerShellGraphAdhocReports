# Connect to Graph PowerShell
Connect-MgGraph -Scopes 'AuditLog.Read.All','Directory.Read.All' -TenantId constoso.onmicrosoft.com

# Get created users in the last 3 days
.\Get-UserCreateActivity.ps1 -StartDate (Get-Date).AddDays(-3) -EndDate (Get-Date)

# Get deleted users in the last 7 days
.\Get-UserDeleteActivity.ps1 -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)

# Get all deleted users that are still in the recycle bin
.\Get-AADDeletedUsers.ps1