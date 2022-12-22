[cmdletbinding()]
param (
    [Parameter()]
    [int]
    $Period = 7
)
# Connect-MgGraph -Scopes 'Directory.ReadWrite.All' -TenantId org.onmicrosoft.com

$timeStamp = "{0:yyyy-MM-ddTHH:mm:ssZ}" -f $((Get-Date).AddDays(-$period))

if ($period) {
    $uri = $('v1.0/directory/deletedItems/microsoft.graph.user?$filter=deletedDateTime ge ' + $timeStamp + '&$select=DeletedDateTime,DisplayName,Mail,Id,UserPrincipalName,UserType')
}
else {
    $uri = $('v1.0/directory/deletedItems/microsoft.graph.user?$select=DeletedDateTime,DisplayName,Mail,Id,UserPrincipalName,UserType')
}

$deletedUsers = (Invoke-MgGraphRequest -Method get -Uri $uri -OutputType PSObject).value | Sort-Object DeletedDateTime -Descending | Select-Object `
@{n = 'When Deleted'; e = { $_.DeletedDateTime } },
@{n = 'Name'; e = { $_.DisplayName } },
Id,
@{n = 'Username'; e = { $_.UserPrincipalName -replace $($_.id -replace '-', ''), '' } },
@{n = 'Email'; e = { $_.Mail } },
UserType

$deletedUsers