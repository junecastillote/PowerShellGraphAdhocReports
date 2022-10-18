[cmdletbinding()]
param (
    [parameter(Mandatory)]
    [datetime]$StartDate,
    [parameter(Mandatory)]
    [datetime]$EndDate,
    [parameter()]
    [switch]$IncludeAuditId
)

"Report date range is: [$StartDate] to [$EndDate]" | Out-Default

$filter = "activityDisplayName eq 'Add user' and activityDateTime ge $("{0:yyyy-MM-ddTHH:mm:ssZ}" -f $($StartDate)) and activityDateTime lt $("{0:yyyy-MM-ddTHH:mm:ssZ}" -f $($EndDate))"

try {
    $audit = Get-MgAuditLogDirectoryAudit -Filter $filter -ErrorAction Stop -All
    foreach ($item in $audit) {
        [pscustomobject]$(
            [ordered]@{
                'Audit Id'          = $(
                    if ($IncludeAuditId) {
                        $item.id
                    }
                )
                'User account'      = $($item.TargetResources.UserPrincipalName -replace $($item.TargetResources.Id -replace '-', ''), '')
                'User account name' = $($item.TargetResources.ModifiedProperties | Where-Object { $_.DisplayName -eq 'DisplayName' }).NewValue | ConvertFrom-Json
                'User account type' = $($item.TargetResources.ModifiedProperties | Where-Object { $_.DisplayName -eq 'UserType' }).NewValue | ConvertFrom-Json
                'Who created'       = $(
                    if ($item.InitiatedBy.App.ServicePrincipalId) { $item.InitiatedBy.App.DisplayName }
                    if ($item.InitiatedBy.User.UserPrincipalName) { $item.InitiatedBy.User.UserPrincipalName }
                )
                'When created'      = $item.activityDateTime
            }
        )
    }
    "Found $($audit.Count) create user activities." | Out-Default
}
catch {
    if ($_.Exception.Message -like "*Minimum allowed time for activityDateTime*") {
        $($_.Exception.Message -replace "activityDateTime", "StartDate and EndDate") | Out-Default
    }
    else {
        $_.Exception.Message | Out-Default
    }
    return $null
}

