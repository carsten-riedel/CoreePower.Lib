Add-Type @'
public enum Scope {
    CurrentUser,
    LocalMachine
}
'@

<#
.SYNOPSIS
Generates a new GUID (Globally Unique Identifier) and returns it as a string.

.EXAMPLE
The following example assigns the generated GUID to a variable named $newGuid:
$newGuid = Generate-GuidAsString

.NOTES
This function has an alias "ggas" for ease of use.
#>

function GenerateGuidAsString {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("ggas")]
    param()
    $guid = New-Guid
    $guidString = $guid.ToString()
    return $guidString
}

<#
.SYNOPSIS
Checks whether the current user is a member of the local administrator group by inspecting the process claim.

.DESCRIPTION
This function checks the current user's process claim to determine whether they are a member of the local administrator group. This method is more accurate than other methods that rely on group membership alone.

.NOTES
This function may not work as expected in certain scenarios, such as when running under a virtualized environment.

.EXAMPLE
The following example checks whether the current user is a local administrator on the machine:
$isAdmin = HasLocalAdministratorClaim

.LINK
https://docs.microsoft.com/en-us/windows/security/identity-protection/access-control/access-control
#>
function HasLocalAdministratorClaim {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    $claims = (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).Claims
    $administratorsSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null)

    foreach ($claim in $claims) {
        if ($claim.Value -eq $administratorsSid.Value) {
            $isAdmin = $true
            break
        }
    }
    return $isAdmin
}

<#
.SYNOPSIS
This function checks whether the current user has local administrator privileges and returns a Boolean value indicating the result.

.EXAMPLE
The following example assigns the Boolean result of the function to a variable named $CanBeAdmin:
$CanBeAdmin = CouldRunAsAdministrator

.PARAMETER
This function does not accept any parameters.

.NOTES
This function has an alias "ilag" for ease of use.
#>

function CouldRunAsAdministrator {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("craa")]
    param()
    $isAdmin = HasLocalAdministratorClaim
    return $isAdmin
}

<#
.SYNOPSIS
Checks whether the current user has sufficient privileges to execute an operation in the desired scope.

.PARAMETER Scope
Specifies the desired scope. This can be one of the following values: "CurrentUser" or "LocalMachine".

.EXAMPLE
The following example checks whether the current user has sufficient privileges to execute an operation in the "LocalMachine" scope:
$canExecute = CanExecuteInDesiredScope -Scope LocalMachine

.NOTES
This function has an alias "cedc" for ease of use.
#>
function CanExecuteInDesiredScope {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cedc")]
    param (
        [Scope]$Scope
    )

    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($Scope -eq [Scope]::CurrentUser) {
        return $true
    } elseif ($Scope -eq [Scope]::LocalMachine) {
        if ($IsAdmin -eq $true) {
            return $true
        } elseif (CouldRunAsAdministrator) {
            # The current user is not running as admin, but is a member of the local admin group
            Write-Error "The operation cannot be executed in the desired scope due to insufficient privileges of the process. You need to run the process as an administrator."
            return $false
        } else {
            # The current user is not an administrator
            Write-Error "The operation cannot be executed in the desired scope due to insufficient privileges of the user. You need to run the process as an administrator for this you need to be member of the local Administrators group."
            return $false
        }
    }
}

# Modify user or machine settings based on the desired scope
function ChangeSomethingScoped {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Position = 0)]
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::CurrentUser)
    {
        # Modify user settings
        Write-Output "Modifying user settings..."
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        # Modify machine settings
        Write-Output "Modifying machine settings..."
    }
}

function EnsureModulePresents {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("emp")]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,
        [Parameter(Mandatory)]
        [string]$ModuleVersion
    )

    #Get module in the current session
    $ModuleAvailableInSession = Get-Module -Name $ModuleName | Where-Object {$_.Version -ge $ModuleVersion}

    if ($ModuleAvailableInSession) {
        return
    }
    else {
        $ModuleAvailableOnSystem = Get-Module -Name $ModuleName -ListAvailable | Where-Object {$_.Version -ge $ModuleVersion}
        
        if ($ModuleAvailableOnSystem) {
            Import-Module -Name $ModuleName -MinimumVersion $ModuleVersion
        } else {
            Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Force
            Import-Module -Name $ModuleName -MinimumVersion $ModuleVersion
        }
    }
}

function ExportPowerShellCustomObject {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expsco")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @()
    )

    $Indent = " " * (4 * $IndentLevel)

    if ($InputObject -is [PSCustomObject]) {
        $Properties = $InputObject | Get-Member -MemberType NoteProperty
    } elseif ($InputObject -is [hashtable]) {
        $Properties = $InputObject.Keys | ForEach-Object { [PSCustomObject]@{ Name = $_ } }
    } else {
        return
    }
    
    $Properties = $Properties | Sort-Object { if ($CustomOrder -notcontains $_.Name) { [int]::MaxValue } else { [array]::IndexOf($CustomOrder, $_.Name) } }, Name

    $Output = @()
    foreach ($Property in $Properties) {
        $PropertyName = $Property.Name
        $PropertyValue = $InputObject.$PropertyName

        if ($PropertyValue -is [string]) {
            $Output += "${Indent}$PropertyName = '$PropertyValue'"
        } elseif ($PropertyValue -is [array]) {
            $ArrayOutput = @()
            foreach ($Item in $PropertyValue) {
                if ($Item -is [string]) {
                    $ArrayOutput += "'$Item'"
                } else {
                    $ArrayOutput += "@{" + (ExportPowerShellCustomObject -InputObject $Item -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) + "}"
                }
            }
            $Output += "${Indent}$PropertyName = @(" + (($ArrayOutput) -join ", ") + ")"
        } elseif ($PropertyValue -is [PSCustomObject] -or $PropertyValue -is [hashtable]) {
            $NestedProperties = (ExportPowerShellCustomObject -InputObject $PropertyValue -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) -split "`n"
            $Output += "${Indent}$PropertyName = @{"
            $Output += $NestedProperties -join "`n"
            $Output += "${Indent}}"
        } else {
            $Output += "${Indent}$PropertyName = $PropertyValue"
        }
    }

    $Output -join "`n"
}

function ExportPowerShellCustomObjectWrapper {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expscow")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @(),
        [string]$Prefix = "",
        [string]$Suffix = ""
    )

    $Output = ""
    $Properties = ExportPowerShellCustomObject -InputObject $InputObject -IndentLevel $IndentLevel -CustomOrder $CustomOrder
    if ($Properties) {
        $Output += $Prefix + "`n"
        $Output += $Properties -join "`n"
        $Output += "`n" + $Suffix
    }
    return $Output
}



function ExportPowerShellCustomObject2 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expsco2")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @()
    )

    $Indent = " " * (4 * $IndentLevel)

    if ($InputObject -is [PSCustomObject]) {
        $Properties = $InputObject | Get-Member -MemberType NoteProperty
    } elseif ($InputObject -is [hashtable]) {
        $Properties = $InputObject.Keys | ForEach-Object { [PSCustomObject]@{ Name = $_ } }
    } else {
        return
    }
    
    $Properties = $Properties | Sort-Object { if ($CustomOrder -notcontains $_.Name) { [int]::MaxValue } else { [array]::IndexOf($CustomOrder, $_.Name) } }, Name

    $Output = @()
    foreach ($Property in $Properties) {
        $PropertyName = $Property.Name
        $PropertyValue = $InputObject.$PropertyName

        if ($PropertyValue -is [string]) {

            # Define the regular expression pattern to match
            $pattern = "^[a-zA-Z0-9_]*$"

            # Use the -match operator to check if the string matches the pattern
            if ($PropertyName -match $pattern) {
                $Output += "${Indent}$PropertyName = '$PropertyValue'"
            } else {
                $Output += "${Indent}`"$PropertyName`" = '$PropertyValue'"
            }
        } elseif ($PropertyValue -is [array]) {
            $ArrayOutput = @()
            foreach ($Item in $PropertyValue) {
                if ($Item -is [string]) {
                    $ArrayOutput += "'$Item'"
                } else {
                    $ArrayOutput += "@{ " + (ExportPowerShellCustomObject2 -InputObject $Item -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) + "}"
                }
            }
            $Output += "${Indent}$PropertyName = @(" + (($ArrayOutput) -join ", ") + ")"
        } elseif ($PropertyValue -is [PSCustomObject] -or $PropertyValue -is [hashtable]) {
            $NestedProperties = (ExportPowerShellCustomObject2 -InputObject $PropertyValue -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) -split "`n"
            $Output += "${Indent}$PropertyName = @{ "
            $Output += $NestedProperties -join "`n"
            $Output += "${Indent}}"
        } else {
            $Output += "${Indent}$PropertyName = $PropertyValue"
        }
    }

    $Output -join "`n"
}

function ExportPowerShellCustomObjectWrapper2 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expscow2")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @(),
        [string]$Prefix = "",
        [string]$Suffix = ""
    )

    $Output = ""
    $Properties = ExportPowerShellCustomObject2 -InputObject $InputObject -IndentLevel $IndentLevel -CustomOrder $CustomOrder
    if ($Properties) {
        $Output += $Prefix + "`n"
        $Output += $Properties -join "`n"
        $Output += "`n" + $Suffix
    }
    return $Output
}
