[CmdletBinding()]
param (
    [Parameter()]
    [int]
    $Period = 7
)

$filter = @"
activityDisplayName eq 'Disable account' and
category eq 'UserManagement' and
result eq 'Success' and
activityDateTime ge $((Get-Date).AddDays(-$ReportPeriod).ToString('yyyy-MM-dd'))
"@

$result = Get-MgAuditLogDirectoryAudit -Filter $filter

foreach ($item in $result) {
    $initiator = ''

    # Get initiator identity
    if ($item.InitiatedBy.User.Id) {
        $initiator = $item.InitiatedBy.User.UserPrincipalName
    }
    if ($item.InitiatedBy.App.AppId) {
        $initiator = $item.InitiatedBy.App.ServicePrincipalName
    }

    # return fields
    [PSCustomObject]@{
        DisabledDateTime = $item.ActivityDateTime
        DisabledUser     = $item.TargetResources.UserPrincipalName
        DisabledBy       = $initiator
    }
}