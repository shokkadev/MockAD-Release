<#
    WARNING: READ BEFORE EXECUTION

    This script is intended for testing, learning, or development purposes only.

    DO NOT run this script in a production environment unless you fully understand
    what it does and have validated its behavior.

    Running scripts without proper review may result in:
        - Unintended changes to Active Directory or system configurations
        - Service disruption or outages
        - Data loss or security exposure

    Before executing:
        - Review and understand all actions performed by this script
        - Test in a non-production (lab) environment
        - Ensure backups and rollback procedures are in place
        - Confirm you have proper authorization

    Use of this script is at your own risk.
#>

param
(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [switch]$IncludeUsers,
    [switch]$IncludeComputers,
    [switch]$IncludeGroups,
    [switch]$IncludeGroupMembers
)

if ($IncludeGroupMembers -and -not $IncludeGroups)
{
    throw "The -IncludeGroupMembers switch requires -IncludeGroups to also be specified."
}

Import-Module ActiveDirectory

function New-Node 
{
    param
    (
        $Name, 
        $Type
    )
    return @{
        Name = $Name
        Type = $Type
        Description = ""
        Children = @()
    }
}

Write-Host "Building MockAD export..." -ForegroundColor Cyan

$domain = Get-ADDomain

$root = New-Node $domain.DNSRoot "Domain"

# --- OUs ---
$ouMap = @{}
$ous = Get-ADOrganizationalUnit -Filter *

foreach ($ou in $ous) 
{
    $node = New-Node $ou.Name "OU"
    $ouMap[$ou.DistinguishedName] = $node
}

# Attach OUs
foreach ($ou in $ous) {
    $dn = $ou.DistinguishedName
    $parentDN = ($dn -split ',', 2)[1]

    if ($ouMap.ContainsKey($parentDN)) 
    {
        $ouMap[$parentDN].Children += $ouMap[$dn]
    }
    elseif ($parentDN -eq $domain.DistinguishedName) 
    {
        $root.Children += $ouMap[$dn]
    }
}

# Helper: Ensure logical OU exists
function Ensure-ChildOU {
    param($parent, $name)

    $existing = $parent.Children | Where-Object { $_.Name -eq $name -and $_.Type -eq "OU" }
    if ($existing) 
    { 
        return $existing 
    }

    $new = New-Node $name "OU"
    $parent.Children += $new
    return $new
}

# --- Users ---
$userMap = @{}
if ($IncludeUsers) {
    Write-Host "Processing Users..." -ForegroundColor Yellow

    $users = Get-ADUser -Filter * -Properties DistinguishedName

    foreach ($user in $users) 
    {
        $node = New-Node $user.SamAccountName "User"
        $userMap[$user.DistinguishedName] = $node

        $parentDN = ($user.DistinguishedName -split ',', 2)[1]

        if ($ouMap.ContainsKey($parentDN)) 
        {
            $usersOU = Ensure-ChildOU $ouMap[$parentDN] "Users"
            $usersOU.Children += $node
        }
    }
}

# --- Computers ---
if ($IncludeComputers) {
    Write-Host "Processing Computers..." -ForegroundColor Yellow

    $computers = Get-ADComputer -Filter *

    foreach ($comp in $computers) 
    {
        $node = New-Node $comp.Name "Computer"

        $parentDN = ($comp.DistinguishedName -split ',', 2)[1]

        if ($ouMap.ContainsKey($parentDN)) 
        {
            $compOU = Ensure-ChildOU $ouMap[$parentDN] "Computers"
            $compOU.Children += $node
        }
    }
}

# --- Groups ---
if($IncludeGroups)
{
    Write-Host "Processing Groups..." -ForegroundColor Yellow

    $groupMap = @{}
    $groups = Get-ADGroup -Filter *

    foreach ($group in $groups) {
        $node = New-Node $group.Name "Group"
        $groupMap[$group.DistinguishedName] = $node

        $parentDN = ($group.DistinguishedName -split ',', 2)[1]

        if ($ouMap.ContainsKey($parentDN)) 
        {
            $groupsOU = Ensure-ChildOU $ouMap[$parentDN] "Groups"
            $groupsOU.Children += $node
        }
    }
}

# --- Group Membership Expansion ---
if(($IncludeGroups) -and ($IncludeGroupMembers))
{
    Write-Host "Expanding group memberships..." -ForegroundColor Yellow

    foreach ($group in $groups) {
        $groupNode = $groupMap[$group.DistinguishedName]

        try {
            $members = Get-ADGroupMember $group.DistinguishedName -ErrorAction Stop

            foreach ($member in $members) {
                switch ($member.objectClass) {
                    "user" {
                        if ($userMap.ContainsKey($member.DistinguishedName)) {
                            $groupNode.Children += $userMap[$member.DistinguishedName]
                        }
                    }
                    "group" {
                        if ($groupMap.ContainsKey($member.DistinguishedName)) {
                            $groupNode.Children += $groupMap[$member.DistinguishedName]
                        }
                    }
                }
            }
        }
        catch {
            Write-Warning "Failed to expand group: $($group.Name)"
        }
    }
}

# --- Export ---
Write-Host "Exporting JSON..." -ForegroundColor Cyan
$root | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 $OutputPath

Write-Host "MockAD export complete!" -ForegroundColor Green
